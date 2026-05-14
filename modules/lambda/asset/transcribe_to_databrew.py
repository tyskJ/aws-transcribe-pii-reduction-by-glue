"""
Transcribe出力をcsv形式に成形
"""

import json
import csv
import boto3
from io import StringIO
from pathlib import Path
from typing import Dict, Any, List

"""
共通ロジック
"""
def transcribe_json_to_rows(data: Dict[str, Any]) -> List[List[Any]]:
    """
    Amazon Transcribe の JSON 出力を、
    DataBrew で扱いやすい「1行=1発話」の行構造に変換する。

    - 話者数は可変（spk_0, spk_1, spk_2, ...）
    - speaker_label はそのまま保持（変換しない）
    """

    rows = []

    """ Transcribe の speaker 分離結果は audio_segments に入っている """
    audio_segments = data.get("results", {}).get("audio_segments", [])

    for seg in audio_segments:
        text = seg.get("transcript", "").strip()
        if not text:
            # 空文字は CSV に出さない
            continue

        rows.append([
            float(seg["start_time"]),          # 発話開始時間
            float(seg["end_time"]),            # 発話終了時間
            seg.get("speaker_label"),          # spk_0 / spk_1 / spk_2 ...
            text                               # 発話内容
        ])

    return rows


def rows_to_csv(rows: List[List[Any]]) -> str:
    """
    行データ（list）を CSV 形式の「文字列」に変換する。

    ※ ファイルは作らない
    ※ Lambda でそのまま S3 put するための形式
    """

    buffer = StringIO()
    writer = csv.writer(buffer)

    # DataBrew 用のヘッダ
    writer.writerow([
        "start_time",
        "end_time",
        "speaker_label",
        "text"
    ])

    writer.writerows(rows)

    """ CSV 全体を文字列として取得 """
    return buffer.getvalue()


"""
Lambda handler
"""
def lambda_handler(event, context):
    """
    Step Functions から呼ばれる Lambda。

    event 想定：
    {
      "input": {
        "bucket": "transcribe-output-bucket",
        "key": "job-123/output.json"
      },
      "output": {
        "bucket": "databrew-input-bucket",
        "key": "job-123/normalized.csv"
      }
    }
    """

    """
    入力取得（S3 → JSON）
    """
    input_bucket = event["input"]["bucket"]
    input_key = event["input"]["key"]

    s3 = boto3.client("s3")
    obj = s3.get_object(
        Bucket=input_bucket,
        Key=input_key
    )

    transcribe_json = json.loads(
        obj["Body"].read().decode("utf-8")
    )

    """
    変換処理
    """
    rows = transcribe_json_to_rows(transcribe_json)
    csv_text = rows_to_csv(rows)

    """
    出力（CSV → 別バケットへ）
    """
    output_bucket = event["output"]["bucket"]
    output_key = event["output"]["key"]

    s3.put_object(
        Bucket=output_bucket,
        Key=output_key,
        Body=csv_text.encode("utf-8"),
        ContentType="text/csv"
    )

    return {
        "status": "SUCCESS",
        "rows": len(rows),
        "output": {
            "bucket": output_bucket,
            "key": output_key
        }
    }

"""
ローカル実行用
"""
if __name__ == "__main__":
    """
    ローカルでの動作確認用。

    例：
      python transcribe_to_databrew.py input.json output.csv
    """

    import sys

    if len(sys.argv) != 3:
        print("Usage: python transcribe_to_databrew.py input.json output.csv")
        sys.exit(1)

    input_json_path = Path(sys.argv[1])
    output_csv_path = Path(sys.argv[2])

    """ Transcribe JSON を読み込む """
    with input_json_path.open("r", encoding="utf-8") as f:
        data = json.load(f)

    """ 変換 """
    rows = transcribe_json_to_rows(data)

    """ CSV ファイルとして書き出し """
    with output_csv_path.open("w", encoding="utf-8", newline="") as f:
        writer = csv.writer(f)
        writer.writerow([
            "start_time",
            "end_time",
            "speaker_label",
            "text"
        ])
        writer.writerows(rows)

    print(f"Converted {len(rows)} rows → {output_csv_path}")
