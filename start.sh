#!/bin/bash
set -e

if [ -z "$TG_RTMP" ] || [ -z "$TG_KEY" ]; then
  echo "Missing env: TG_RTMP, TG_KEY"
  exit 1
fi

(
  while true; do
    echo "Streaming black screen + music -> rtmp://$TG_RTMP/$TG_KEY"

    ffmpeg -hide_banner -loglevel warning \
      -f lavfi -i "color=c=black:s=1080x1920:r=${FPS}" \
      -i music.mp3 \
      -shortest \
      -c:v libx264 -preset "${X264_PRESET}" -b:v "${VIDEO_BITRATE}" -maxrate "${VIDEO_BITRATE}" -bufsize "$((2*${VIDEO_BITRATE%k}))k" \
      -c:a aac -b:a "${AUDIO_BITRATE}" -ar 44100 \
      -f flv "rtmp://$TG_RTMP/$TG_KEY"

    echo "FFmpeg exited. Reconnect in 5s..."
    sleep 5
  done
) &

python3 -m http.server 8080