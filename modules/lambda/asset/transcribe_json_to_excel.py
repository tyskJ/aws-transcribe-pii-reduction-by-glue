"""
- Transcribe出力をExcel形式(.xlsx)に成形
- エラーハンドリングは Step Functions 側に任せる
"""

import json
import boto3
from io import BytesIO
from pathlib import Path
from typing import Dict, Any, List
from openpyxl import Workbook

"""
共通ロジック
"""
def transcribe_json_to_rows(data: Dict[str, Any]) -> List[List[Any]]:
    """
    Amazon Transcribe JSON → 行データ
    """

    rows = []

    """ Transcribe の speaker 分離結果は audio_segments に入っている """
    audio_segments = data.get("results", {}).get("audio_segments", [])

    for seg in audio_segments:
        text = seg.get("transcript", "").strip()
        if not text:
            continue

        rows.append([
            float(seg["start_time"]),          # 発話開始時間
            float(seg["end_time"]),            # 発話終了時間
            seg.get("speaker_label"),          # spk_0 / spk_1 / spk_2 ...
            text                               # 発話内容
        ])

    return rows


def rows_to_excel_bytes(rows: List[List[Any]]) -> bytes:
    """
    行データ → Excel（バイト列）
    """

    wb = Workbook()
    ws = wb.active
    ws.title = "transcribe"

    # ヘッダ
    ws.append([
        "start_time",
        "end_time",
        "speaker_label",
        "text"
    ])

    # データ
    for row in rows:
        ws.append(row)

    buffer = BytesIO()
    wb.save(buffer)

    return buffer.getvalue()


"""
Lambda handler
"""
def lambda_handler(event, context):
    """
    Step Functions から呼ばれる Lambda。

    event 想定：
    {
        "inputBucket": "transcribe-json-bucket",
        "inputKey": "json-file",
        "outputBucket": "glue-excel-bucket",
        "outputKey": "excel-file" 
    }
    """

    """
    入力取得（S3 → JSON）
    """
    input_bucket = event["inputBucket"]
    input_key = event["inputKey"]

    s3 = boto3.client("s3")

    """ Transcribe JSON取得 """
    obj = s3.get_object(Bucket=input_bucket, Key=input_key)
    transcribe_json = json.loads(obj["Body"].read().decode("utf-8"))

    """
    変換処理
    """
    rows = transcribe_json_to_rows(transcribe_json)
    excel_bytes = rows_to_excel_bytes(rows)

    """
    出力（EXCEL → 別バケットへ）
    """
    output_bucket = event["outputBucket"]
    output_key = event["outputKey"]  # 必ず .xlsx にする

    s3.put_object(
        Bucket=output_bucket,
        Key=output_key,
        Body=excel_bytes,
        ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
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

    import sys

    if len(sys.argv) != 3:
        print("Usage: python transcribe_json_to_excel.py input.json output.xlsx")
        sys.exit(1)

    input_json_path = Path(sys.argv[1])
    output_excel_path = Path(sys.argv[2])

    # --- JSON読込 ---
    with input_json_path.open("r", encoding="utf-8") as f:
        data = json.load(f)

    # --- 変換 ---
    rows = transcribe_json_to_rows(data)

    # --- Excel出力 ---
    wb = Workbook()
    ws = wb.active

    ws.append([
        "start_time",
        "end_time",
        "speaker_label",
        "text"
    ])

    for row in rows:
        ws.append(row)

    wb.save(output_excel_path)

    print(f"Converted {len(rows)} rows → {output_excel_path}")