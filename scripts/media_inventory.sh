#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: media_inventory.sh <media-folder>" >&2
  exit 2
fi

source_dir=$1
if [[ ! -d "$source_dir" ]]; then
  echo "Media folder not found: $source_dir" >&2
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
printf 'file\tduration\tresolution\tfps\tvideo_codec\taudio\n'

while IFS= read -r -d '' media_file; do
  probe=$("$ffmpeg_bin" -hide_banner -i "$media_file" 2>&1 || true)
  duration=$(sed -nE 's/.*Duration: ([0-9:.]+),.*/\1/p' <<<"$probe" | head -n 1)
  video_line=$(sed -n '/Video:/{p;q;}' <<<"$probe")
  audio_line=$(sed -n '/Audio:/{p;q;}' <<<"$probe")
  resolution=$(sed -nE 's/.* ([0-9]{2,5}x[0-9]{2,5})([ ,].*)?/\1/p' <<<"$video_line" | head -n 1)
  fps=$(sed -nE 's/.*, ([0-9.]+) fps.*/\1/p' <<<"$video_line" | head -n 1)
  codec=$(sed -nE 's/.*Video: ([^ ,]+).*/\1/p' <<<"$video_line" | head -n 1)
  if [[ -n "$audio_line" ]]; then
    audio=yes
  else
    audio=no
  fi
  printf '%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$media_file" "${duration:-unknown}" "${resolution:-unknown}" \
    "${fps:-unknown}" "${codec:-unknown}" "$audio"
done < <(
  find "$source_dir" -type f \
    \( -iname '*.mp4' -o -iname '*.mov' -o -iname '*.m4v' -o -iname '*.avi' -o -iname '*.mkv' \) \
    ! -name '._*' -print0 | sort -z
)
