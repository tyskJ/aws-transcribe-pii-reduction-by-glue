"""
Pollyで話者ごとにPCM生成 → 連結 → (劣化) → WAV化 → S3保存
Transcribe(バッチ)にそのまま投げられるWAVを作る用途
"""

import boto3
import wave
import random
from io import BytesIO
from array import array
from typing import List, Dict, Any, Tuple

polly = boto3.client("polly", region_name="ap-northeast-1")
s3 = boto3.client("s3")

# ====== 設定（デフォルト） ======
DEFAULT_SAMPLE_RATE = 16000  # 自然さ優先。音質劣化は後段で実施
SAMPLE_WIDTH_BYTES = 2       # 16bit PCM

DEFAULT_DIALOGUE: List[Tuple[str, str]] = [
    ("Takumi", "もしもし。お世話になっております。山田太郎と申します。"),
    ("Kazuha", "お電話ありがとうございます。防災サービス窓口の担当です。"),
    ("Takumi", "すみません。登録確認のメールを削除してしまいまして。再送が可能か、確認したくてお電話しました。"),
    ("Kazuha", "はい、承知しました。念のため、ご本人確認をさせてください。お名前は、山田太郎さんでお間違いないでしょうか。"),
    ("Takumi", "はい、山田太郎です。"),
    ("Kazuha", "ありがとうございます。それでは、ご登録の電話番号をお願いいたします。"),
    ("Takumi", "はい。090-1234-5678 です。"),
    ("Kazuha", "復唱いたします。090-1234-5678 ですね。続いて、メールアドレスをお願いいたします。"),
    ("Takumi", "yamada.taro@example.com です。"),
    ("Kazuha", "ありがとうございます。では、内容を確認いたしますので、少々お待ちください。"),
    ("Takumi", "はい、お願いします。"),
    ("Kazuha", "お待たせいたしました。確認メールは、本日中に再送いたします。届かない場合は、迷惑メールフォルダもご確認ください。"),
    ("Takumi", "承知しました。ちなみに、再送はだいたい何時ごろになりますか。"),
    ("Kazuha", "目安にはなりますが、夕方ごろまでにはお届けできる見込みです。"),
    ("Takumi", "分かりました。ありがとうございます。よろしくお願いします。"),
    ("Kazuha", "こちらこそ、よろしくお願いいたします。")
]

def synthesize_pcm(voice_id: str, text: str, engine: str, sample_rate: int) -> bytes:
    # SSMLは最小にして失敗要因を減らす
    ssml = f"<speak>{text}</speak>"
    res = polly.synthesize_speech(
        Engine=engine,
        VoiceId=voice_id,
        TextType="ssml",
        Text=ssml,
        OutputFormat="pcm",
        SampleRate=str(sample_rate),
    )
    return res["AudioStream"].read()

def silence_pcm(duration_ms: int, sample_rate: int) -> bytes:
    samples = int(sample_rate * (duration_ms / 1000.0))
    return b"\x00\x00" * samples

def degrade_pcm(pcm: bytes, noise_level: int = 250, crush_bits: int = 2, dropout_prob: float = 0.0) -> bytes:
    """
    “実際っぽい”低品質に寄せる（やり過ぎない）
    - noise_level: 200〜500くらいが自然
    - crush_bits : 2〜3くらいが自然
    - dropout_prob: 0〜0.01程度（たまにサンプルを0にする）
    """
    samples = array("h")
    samples.frombytes(pcm)

    mask = ~((1 << crush_bits) - 1)

    for i in range(len(samples)):
        v = samples[i]

        # ドロップアウト（まれに瞬間無音）
        if dropout_prob > 0.0 and random.random() < dropout_prob:
            samples[i] = 0
            continue

        # ノイズ
        v += random.randint(-noise_level, noise_level)

        # ビット落とし（量子化）
        v = v & mask

        # クリップ
        if v > 32767:
            v = 32767
        elif v < -32768:
            v = -32768

        samples[i] = v

    return samples.tobytes()

def pcm_to_wav_bytes(pcm: bytes, sample_rate: int) -> bytes:
    """
    PCM(16bit/mono)にWAVヘッダを付与
    WAVはPCM＋ヘッダなので wave で書けばOK。[1](https://aws.amazon.com/blogs/machine-learning/integrating-amazon-polly-with-legacy-ivr-systems-by-converting-output-to-wav-format/)[2](https://jun711.github.io/aws/convert-aws-polly-synthesized-speech-from-pcm-to-wav-format/)
    """
    buf = BytesIO()
    with wave.open(buf, "wb") as wf:
        wf.setnchannels(1)
        wf.setsampwidth(SAMPLE_WIDTH_BYTES)
        wf.setframerate(sample_rate)
        wf.writeframes(pcm)
    return buf.getvalue()

def pad_to_target_size_pcm(pcm: bytes, sample_rate: int, target_wav_bytes: int) -> bytes:
    """
    WAVサイズを target に近づけるために末尾へ無音を追加（PCM側で調整）
    WAVヘッダは約44byteなので、PCM側は target-44 を目安にする。
    """
    header = 44
    target_pcm_bytes = max(0, target_wav_bytes - header)

    if len(pcm) >= target_pcm_bytes:
        return pcm  # すでに十分なら触らない（少し超過は許容）

    need = target_pcm_bytes - len(pcm)

    # 16bit mono のため、必ず偶数バイトに丸める
    if need % 2 == 1:
        need += 1

    # 無音で埋める
    return pcm + (b"\x00\x00" * (need // 2))

"""
Lambda Handler
"""
def lambda_handler(event: Dict[str, Any], context):
    """
    event例：
    {
      "outputBucket": "your-bucket",
      "outputKey": "test/pii_dialogue.wav",

      // 任意
      "engine": "neural",         // 自然さ優先なら neural（複数voiceでも1発話ずつならOK）
      "sampleRate": 16000,        // 2MB狙いは16kがラク
      "gapMs": 450,               // 発話間の無音
      "targetWavBytes": 2097152,  // 2MB = 2*1024*1024

      // 劣化パラメータ（控えめ推奨）
      "noiseLevel": 280,
      "crushBits": 2,
      "dropoutProb": 0.002,

      // 台本差し替え
      "dialogue": [{"voiceId":"Takumi","text":"..."}, ...]
    }
    """

    out_bucket = event["outputBucket"]
    out_key = event["outputKey"]

    engine = event.get("engine", "neural")  # 自然さ優先
    sample_rate = int(event.get("sampleRate", DEFAULT_SAMPLE_RATE))
    gap_ms = int(event.get("gapMs", 450))
    target_wav_bytes = int(event.get("targetWavBytes", 2 * 1024 * 1024))

    noise_level = int(event.get("noiseLevel", 280))
    crush_bits = int(event.get("crushBits", 2))
    dropout_prob = float(event.get("dropoutProb", 0.002))

    dialogue_in = event.get("dialogue")
    if dialogue_in:
        dialogue = [(d["voiceId"], d["text"]) for d in dialogue_in]
    else:
        dialogue = DEFAULT_DIALOGUE

    # 1) 発話ごとPCM生成 + 間（無音）を挿入して連結
    pcm_chunks: List[bytes] = []
    for i, (voice_id, text) in enumerate(dialogue):
        pcm_chunks.append(synthesize_pcm(voice_id, text, engine, sample_rate))
        if i < len(dialogue) - 1:
            pcm_chunks.append(silence_pcm(gap_ms, sample_rate))

    merged_pcm = b"".join(pcm_chunks)

    # 2) “実運用っぽい”軽い劣化（やりすぎない）
    merged_pcm = degrade_pcm(
        merged_pcm,
        noise_level=noise_level,
        crush_bits=crush_bits,
        dropout_prob=dropout_prob
    )

    # 3) 2MB付近に寄せる（足りなければ末尾無音で調整）
    merged_pcm = pad_to_target_size_pcm(merged_pcm, sample_rate, target_wav_bytes)

    # 4) PCM → WAV
    wav_bytes = pcm_to_wav_bytes(merged_pcm, sample_rate)

    # 5) S3へ保存
    s3.put_object(
        Bucket=out_bucket,
        Key=out_key,
        Body=wav_bytes,
        ContentType="audio/wav"
    )

    return {
        "status": "SUCCESS",
        "engine": engine,
        "sampleRate": sample_rate,
        "wavBytes": len(wav_bytes),
        "output": {"bucket": out_bucket, "key": out_key}
    }
