import json
import csv
import os
from pathlib import Path
from typing import Dict, Any, List


def transcribe_json_to_rows(data: Dict[str, Any]) -> List[List[Any]]:
    """
    Amazon Transcribe JSON を DataBrew 向けの行データに変換
    """
    rows = []
    audio_segments = data["results"].get("audio_segments", [])

    for seg in audio_segments:
        text = seg.get("transcript", "").strip()
        if not text:
            continue

        rows.append([
            float(seg["start_time"]),
            float(seg["end_time"]),
            seg.get("speaker_label"),
            text
        ])

    return rows


def write_csv(rows: List[List[Any]], output_path: Path) -> None:
    with open(output_path, "w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(["start_time", "end_time", "speaker_label", "text"])
        writer.writerows(rows)


# -------------------------
# Lambda handler
# -------------------------
def lambda_handler(event, context):
    """
    Step Functions から呼ばれる想定
    event:
      {
        "input_s3_path": "/tmp/input.json",
        "output_s3_path": "/tmp/output.csv"
      }
    ※ 実運用では S3 Get/Put に差し替え
    """
    input_path = Path(event["input_s3_path"])
    output_path = Path(event["output_s3_path"])

    with open(input_path, "r", encoding="utf-8") as f:
        data = json.load(f)

    rows = transcribe_json_to_rows(data)
    write_csv(rows, output_path)

    return {
        "status": "SUCCESS",
        "rows": len(rows),
        "output": str(output_path)
    }


# -------------------------
# Local execution
# -------------------------
if __name__ == "__main__":
    import sys

    if len(sys.argv) != 3:
        print("Usage: python transcribe_to_databrew.py input.json output.csv")
        sys.exit(1)

    input_json = Path(sys.argv[1])
    output_csv = Path(sys.argv[2])

    with open(input_json, "r", encoding="utf-8") as f:
        data = json.load(f)

    rows = transcribe_json_to_rows(data)
    write_csv(rows, output_csv)

    print(f"Converted {len(rows)} rows → {output_csv}")