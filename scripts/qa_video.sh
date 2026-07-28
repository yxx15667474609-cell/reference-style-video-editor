#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: qa_video.sh <video>" >&2
  exit 2
fi

video=$1
if [[ ! -f "$video" ]]; then
  echo "Video not found: $video" >&2
  exit 2
fi

resolve_ffmpeg() {
  if [[ -n "${FFMPEG_BIN:-}" && -x "${FFMPEG_BIN}" ]]; then
    printf '%s\n' "${FFMPEG_BIN}"
  elif command -v ffmpeg >/dev/null 2>&1; then
    command -v ffmpeg
  elif [[ -x "$PWD/.codex-video-work/ffmpeg-node/node_modules/ffmpeg-static/ffmpeg" ]]; then
    printf '%s\n' "$PWD/.codex-video-work/ffmpeg-node/node_modules/ffmpeg-static/ffmpeg"
  else
    echo "ffmpeg not found. Set FFMPEG_BIN or install ffmpeg." >&2
    exit 127
  fi
}

ffmpeg_bin=$(resolve_ffmpeg)

echo "== Streams =="
"$ffmpeg_bin" -hide_banner -i "$video" -f null - 2>&1 | sed -n '1,22p'

echo "== Full decode =="
"$ffmpeg_bin" -hide_banner -v error -xerror -i "$video" \
  -map 0:v:0 -map 0:a:0? -f null -
echo "decode_ok"

echo "== Black/freeze scan =="
detection=$(
  "$ffmpeg_bin" -hide_banner -loglevel info -i "$video" -an \
    -vf "blackdetect=d=0.20:pix_th=0.10,freezedetect=n=-50dB:d=0.80" \
    -f null - 2>&1 | sed -n '/black_/p;/freeze_/p'
)
if [[ -n "$detection" ]]; then
  printf '%s\n' "$detection"
else
  echo "no_black_or_freeze_events"
fi

echo "== Audio level =="
"$ffmpeg_bin" -hide_banner -i "$video" -map 0:a:0? \
  -af volumedetect -f null - 2>&1 |
  sed -n '/mean_volume/p;/max_volume/p'

echo "== SHA-256 =="
shasum -a 256 "$video"
