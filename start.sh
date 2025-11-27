#!/bin/bash
set -e

if [ -z "$YT_URL" ] || [ -z "$TG_RTMP" ] || [ -z "$TG_KEY" ]; then
  echo "Missing env: YT_URL, TG_RTMP, TG_KEY"
  exit 1
fi

# Получаем прямую HLS ссылку на YouTube
get_hls() {
  yt-dlp -g "$YT_URL" 2>/dev/null | tail -n 1
}

while true; do
  HLS_URL="$(get_hls)"
  if [ -z "$HLS_URL" ]; then
    echo "Failed to get HLS URL. Retry in 10s..."
    sleep 10
    continue
  fi

  echo "Relay: $HLS_URL -> rtmp://$TG_RTMP/$TG_KEY"

  # ffmpeg гонит поток в Telegram
  ffmpeg -hide_banner -loglevel warning \
    -re -i "$HLS_URL" \
    -vf "fps=${FPS}" \
    -c:v libx264 -preset "${X264_PRESET}" -b:v "${VIDEO_BITRATE}" -maxrate "${VIDEO_BITRATE}" -bufsize "$((2*${VIDEO_BITRATE%k}))k" \
    -c:a aac -b:a "${AUDIO_BITRATE}" -ar 44100 \
    -f flv "rtmp://$TG_RTMP/$TG_KEY"

  echo "FFmpeg exited. Reconnect in 5s..."
  sleep 5
done
