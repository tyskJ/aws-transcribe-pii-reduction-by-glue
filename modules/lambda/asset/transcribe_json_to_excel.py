"""
- Transcribe出力をExcel形式(.xlsx)に成形
- Lambda内でTranslate（SDK）実行
- エラーハンドリングなし（Step Functions側）
"""

import sys
import os

# ローカルだけ path 追加
if not os.getenv("AWS_EXECUTION_ENV"):
    sys.path.insert(0, os.path.join(os.path.dirname(__file__), "vendor"))

import json
from io import BytesIO
from pathlib import Path
from typing import Dict, Any, List
import boto3
from openpyxl import Workbook

"""
共通ロジック
"""
def transcribe_json_to_rows(data: Dict[str, Any], translate_client) -> List[List[Any]]:
    """
    Transcribe JSON → 行データ + 英語変換
    """

    rows = []
    audio_segments = data.get("results", {}).get("audio_segments", [])

    for seg in audio_segments:
        text = seg.get("transcript", "").strip()
        if not text:
            continue

        # --- Translate（同期） ---
        translated_text = translate_client.translate_text(
            Text=text,
            SourceLanguageCode="ja",
            TargetLanguageCode="en"
        )["TranslatedText"]

        rows.append([
            float(seg["start_time"]),
            float(seg["end_time"]),
            seg.get("speaker_label"),
            text,              # 元日本語
            translated_text    # 英語
        ])

    return rows


def rows_to_excel_bytes(rows: List[List[Any]]) -> bytes:
    """
    行データ → Excel
    """

    wb = Workbook()
    ws = wb.active
    ws.title = "transcribe"

    ws.append([
        "start_time",
        "end_time",
        "speaker_label",
        "text",
        "text_en"
    ])

    for row in rows:
        ws.append(row)

    buffer = BytesIO()
    wb.save(buffer)

    return buffer.getvalue()

"""
Lambda Handler
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

    input_bucket = event["inputBucket"]
    input_key = event["inputKey"]

    output_bucket = event["outputBucket"]
    output_key = event["outputKey"]

    s3 = boto3.client("s3")
    translate = boto3.client("translate")

    """ JSON取得 """
    obj = s3.get_object(Bucket=input_bucket, Key=input_key)
    transcribe_json = json.loads(obj["Body"].read().decode("utf-8"))

    """ 変換（Translate込み） """
    rows = transcribe_json_to_rows(transcribe_json, translate)
    excel_bytes = rows_to_excel_bytes(rows)

    """ 出力 """
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
ローカル実行
"""
if __name__ == "__main__":

    if len(sys.argv) != 3:
        print("Usage: python transcribe_json_to_excel.py input.json output.xlsx")
        sys.exit(1)

    input_json_path = Path(sys.argv[1])
    output_excel_path = Path(sys.argv[2])

    session = boto3.Session(profile_name="admin")
    translate = session.client("translate", region_name="ap-northeast-1")

    with input_json_path.open("r", encoding="utf-8") as f:
        data = json.load(f)

    rows = transcribe_json_to_rows(data, translate)

    wb = Workbook()
    ws = wb.active

    ws.append([
        "start_time",
        "end_time",
        "speaker_label",
        "text",
        "text_en"
    ])

    for row in rows:
        ws.append(row)

    wb.save(output_excel_path)

    print(f"Converted {len(rows)} rows → {output_excel_path}")