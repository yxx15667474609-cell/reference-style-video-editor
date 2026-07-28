#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 || $# -gt 3 ]]; then
  echo "Usage: contact_sheet.sh <video> <output.png> [frame-count]" >&2
  exit 2
fi

video=$1
output=$2
frame_count=${3:-20}

if [[ ! -f "$video" ]]; then
  echo "Video not found: $video" >&2
  exit 2
fi
if ! [[ "$frame_count" =~ ^[1-9][0-9]*$ ]]; then
  echo "Frame count must be a positive integer." >&2
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
probe=$("$ffmpeg_bin" -hide_banner -i "$video" 2>&1 || true)
duration_hms=$(sed -nE 's/.*Duration: ([0-9:.]+),.*/\1/p' <<<"$probe" | head -n 1)
if [[ -z "$duration_hms" ]]; then
  echo "Could not determine video duration." >&2
  exit 1
fi

duration_seconds=$(awk -F: '{printf "%.6f", ($1 * 3600) + ($2 * 60) + $3}' <<<"$duration_hms")
sample_rate=$(awk -v count="$frame_count" -v duration="$duration_seconds" \
  'BEGIN { printf "%.8f", count / duration }')
columns=$(awk -v count="$frame_count" \
  'BEGIN { for (i=1; i*i<count; i++); print i }')
rows=$(( (frame_count + columns - 1) / columns ))

mkdir -p "$(dirname "$output")"
"$ffmpeg_bin" -hide_banner -loglevel error -y -i "$video" \
  -vf "fps=${sample_rate},scale=360:-2,drawtext=fontcolor=white:fontsize=20:box=1:boxcolor=black@0.65:x=8:y=h-th-8:text='%{pts\\:hms}',tile=${columns}x${rows}:nb_frames=${frame_count}:padding=6:margin=6:color=black" \
  -frames:v 1 "$output"

printf '%s\t%s\t%s\n' "$video" "$duration_hms" "$output"
