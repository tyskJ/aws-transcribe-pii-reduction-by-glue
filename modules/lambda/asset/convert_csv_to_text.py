"""
目的
- DataBrew出力CSV（start_time,end_time,speaker_label,text,text_en）を読み込む
- text_en（英語）を Amazon Translate で日本語化
- 時刻を捨てて、Speakerタグ形式に整形して出力
  [Speaker: spk_0]
  （日本語化した文）
  （次の文）

- Lambda: S3 -> S3
- ローカル: ファイル -> ファイル（必要ならS3入出力も可能）

注意
- TranslateText は入力 Text が最大 10,000 bytes（文字数ではなくbytes）制限 [1](https://docs.aws.amazon.com/translate/latest/APIReference/API_TranslateText.html)[2](https://boto3.amazonaws.com/v1/documentation/api/1.28.17/reference/services/translate/client/translate_text.html)
"""

import os
import sys
import csv
import argparse
from io import StringIO
from pathlib import Path
from typing import Dict, Any, Iterable, List, Tuple

# ローカルだけ path 追加
if not os.getenv("AWS_EXECUTION_ENV"):
    sys.path.insert(0, os.path.join(os.path.dirname(__file__), "vendor"))

import boto3

"""
TranslateTextの上限（bytes）
"""
TRANSLATE_MAX_BYTES = 10_000  # AWS TranslateText の上限（bytes）[1](https://docs.aws.amazon.com/translate/latest/APIReference/API_TranslateText.html)[2](https://boto3.amazonaws.com/v1/documentation/api/1.28.17/reference/services/translate/client/translate_text.html)


def chunk_by_bytes(text: str, max_bytes: int = TRANSLATE_MAX_BYTES) -> List[str]:
    """
    UTF-8 bytes長で max_bytes を超えないように分割する。
    句点や改行で切れたら理想だが、最小実装として安全にバイトで切る。
    """
    if text is None:
        return [""]

    b = text.encode("utf-8")
    if len(b) <= max_bytes:
        return [text]

    chunks: List[str] = []
    start = 0
    while start < len(b):
        end = min(start + max_bytes, len(b))
        # UTF-8境界を壊さないように end を調整
        while end > start and (b[end - 1] & 0b1100_0000) == 0b1000_0000:
            end -= 1
        if end == start:
            # 極端ケース（ほぼ起きないが保険）
            end = min(start + max_bytes, len(b))
        chunks.append(b[start:end].decode("utf-8", errors="ignore"))
        start = end
    return chunks


def translate_text_safe(client, text: str, source_lang: str, target_lang: str) -> str:
    """
    TranslateText を 10,000 bytes 制限に合わせて安全に実行。
    分割した場合は連結して返す。
    """
    parts = chunk_by_bytes(text, TRANSLATE_MAX_BYTES)
    out_parts: List[str] = []

    for p in parts:
        if not p:
            out_parts.append("")
            continue

        resp = client.translate_text(
            Text=p,
            SourceLanguageCode=source_lang,
            TargetLanguageCode=target_lang,
            Settings={
                "Formality": "FORMAL"
            }
        )  # boto3 translate_text [2](https://boto3.amazonaws.com/v1/documentation/api/1.28.17/reference/services/translate/client/translate_text.html)
        out_parts.append(resp["TranslatedText"])

    return "".join(out_parts)


def to_speaker_blocks(rows: Iterable[Tuple[str, str]]) -> str:
    """
    (speaker, text_ja) の列から Speakerタグ形式に整形。
    連続する同一speakerは1ブロックにまとめ、文は行で並べる。
    """
    out_lines: List[str] = []
    current_speaker = None
    current_texts: List[str] = []

    def flush():
        nonlocal current_speaker, current_texts
        if current_speaker is None:
            return
        out_lines.append(f"[Speaker: {current_speaker}]")
        out_lines.extend([t for t in current_texts if t is not None and t != ""])
        out_lines.append("")  # ブロック区切りの空行
        current_speaker = None
        current_texts = []

    for speaker, text_ja in rows:
        if speaker != current_speaker:
            flush()
            current_speaker = speaker
            current_texts = [text_ja]
        else:
            current_texts.append(text_ja)

    flush()
    # 末尾の余分な空行を1つだけに整える
    while len(out_lines) > 0 and out_lines[-1] == "":
        out_lines.pop()
    return "\n".join(out_lines) + "\n"


def convert_csv_text_to_speaker_text(
    csv_text: str,
    translate_client,
    source_lang: str = "en",
    target_lang: str = "ja",
    text_en_col: str = "text_en",
    speaker_col: str = "speaker_label"
) -> str:
    """
    CSV文字列 -> Speakerタグ形式テキスト
    """
    reader = csv.DictReader(StringIO(csv_text))

    translated_pairs: List[Tuple[str, str]] = []
    cache: Dict[str, str] = {}  # 同一文の翻訳をキャッシュ（軽い高速化）

    for row in reader:
        speaker = row.get(speaker_col, "")
        text_en = row.get(text_en_col, "")

        if text_en in cache:
            text_ja = cache[text_en]
        else:
            text_ja = translate_text_safe(translate_client, text_en, source_lang, target_lang)
            cache[text_en] = text_ja

        translated_pairs.append((speaker, text_ja))

    return to_speaker_blocks(translated_pairs)

"""
Lambda handler
"""
def lambda_handler(event: Dict[str, Any], context):
    """
    event例:
    {
      "inputBucket":  "masked-csv-bucket",
      "inputKey":     "databrew-output/pii_include-dataset-recipejob_part00000.csv",
      "outputBucket": "final-text-bucket",
      "outputKey":    "final/out.txt",
      "region": "ap-northeast-1",   // 任意
      "sourceLang": "en",           // 任意
      "targetLang": "ja"            // 任意
    }
    """
    region = event.get("region", os.getenv("AWS_REGION", "ap-northeast-1"))
    source_lang = event.get("sourceLang", "en")
    target_lang = event.get("targetLang", "ja")

    s3 = boto3.client("s3", region_name=region)
    translate = boto3.client("translate", region_name=region)

    in_bucket = event["inputBucket"]
    in_key = event["inputKey"]
    out_bucket = event["outputBucket"]
    out_key = event["outputKey"]

    obj = s3.get_object(Bucket=in_bucket, Key=in_key)
    csv_text = obj["Body"].read().decode("utf-8")

    speaker_text = convert_csv_text_to_speaker_text(
        csv_text=csv_text,
        translate_client=translate,
        source_lang=source_lang,
        target_lang=target_lang
    )

    s3.put_object(
        Bucket=out_bucket,
        Key=out_key,
        Body=speaker_text.encode("utf-8"),
        ContentType="text/plain; charset=utf-8"
    )

    return {
        "status": "SUCCESS",
        "output": {"bucket": out_bucket, "key": out_key},
        "sourceLang": source_lang,
        "targetLang": target_lang
    }

"""
ローカル実行
"""
def main():
    parser = argparse.ArgumentParser(description="Convert DataBrew masked CSV to Speaker-tagged text.")
    parser.add_argument("input_csv", help="input CSV file path")
    parser.add_argument("output_txt", help="output text file path")
    parser.add_argument("--profile", default=None, help="AWS profile name (optional)")
    parser.add_argument("--region", default="ap-northeast-1", help="AWS region")
    parser.add_argument("--source-lang", default="en", help="source language code (default: en)")
    parser.add_argument("--target-lang", default="ja", help="target language code (default: ja)")
    args = parser.parse_args()

    # ローカルはプロファイル指定できるようにする（SSO利用等を想定）
    if args.profile:
        # python convert_csv_to_text.py input.csv output.txt --profile admin
        session = boto3.Session(profile_name=args.profile, region_name=args.region)
        translate = session.client("translate", region_name=args.region)
    else:
        # python convert_csv_to_text.py input.csv output.txt --region ap-northeast-1
        translate = boto3.client("translate", region_name=args.region)

    csv_text = Path(args.input_csv).read_text(encoding="utf-8")
    speaker_text = convert_csv_text_to_speaker_text(
        csv_text=csv_text,
        translate_client=translate,
        source_lang=args.source_lang,
        target_lang=args.target_lang
    )

    Path(args.output_txt).write_text(speaker_text, encoding="utf-8")
    print(f"Written: {args.output_txt}")


if __name__ == "__main__":
    main()