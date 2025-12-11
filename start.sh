#!/bin/bash
set -e

if [ -z "$TG_RTMP" ] || [ -z "$TG_KEY" ]; then
  echo "Missing env: TG_RTMP, TG_KEY"
  exit 1
fi

(
  while true; do
    echo "Streaming local mp4 file -> rtmp://$TG_RTMP/$TG_KEY"

    ffmpeg -hide_banner -loglevel warning \
      -re -stream_loop -1 -i music.mp4 \
      -vf "scale=1080:-2, pad=1080:1920:(ow-iw)/2:(oh-ih)/2, fps=${FPS}" \
      -c:v libx264 -preset "${X264_PRESET}" -b:v "${VIDEO_BITRATE}" -maxrate "${VIDEO_BITRATE}" -bufsize "$((2*${VIDEO_BITRATE%k}))k" \
      -c:a aac -b:a "${AUDIO_BITRATE}" -ar 44100 \
      -f flv "rtmp://$TG_RTMP/$TG_KEY"

    echo "FFmpeg exited. Reconnect in 5s..."
    sleep 5
  done
) &

# Health-check для Render
python3 -m http.server 8080