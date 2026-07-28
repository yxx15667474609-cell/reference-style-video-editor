#!/usr/bin/env python3
import argparse
import json
from pathlib import Path

import mlx_whisper


def json_default(value):
    item = getattr(value, "item", None)
    if callable(item):
        return item()
    raise TypeError(f"Unsupported JSON value: {type(value)!r}")


parser = argparse.ArgumentParser()
parser.add_argument("source_dir")
parser.add_argument("output_dir")
parser.add_argument("--model", default="mlx-community/whisper-small-mlx")
parser.add_argument("--language", default="en")
parser.add_argument("--force", action="store_true")
args = parser.parse_args()

source_dir = Path(args.source_dir)
output_dir = Path(args.output_dir)
output_dir.mkdir(parents=True, exist_ok=True)

media_files = sorted(
    path
    for path in source_dir.iterdir()
    if path.suffix.lower() in {".mp4", ".mov", ".m4v", ".wav", ".mp3", ".m4a"}
    and not path.name.startswith("._")
)

if not media_files:
    raise SystemExit(f"No supported media found in {source_dir}")

for index, media in enumerate(media_files, start=1):
    output = output_dir / f"{media.stem}.json"
    if not args.force and output.exists() and output.stat().st_size > 1000:
        print(f"[{index:02d}/{len(media_files):02d}] cached {media.name}", flush=True)
        continue
    result = mlx_whisper.transcribe(
        str(media),
        path_or_hf_repo=args.model,
        language=args.language,
        task="transcribe",
        word_timestamps=True,
        verbose=False,
    )
    output.write_text(
        json.dumps(result, ensure_ascii=False, default=json_default, indent=2),
        encoding="utf-8",
    )
    summary = " ".join(result.get("text", "").split())
    print(
        f"[{index:02d}/{len(media_files):02d}] {media.name}: {summary[:240]}",
        flush=True,
    )
