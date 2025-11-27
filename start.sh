#!/bin/bash
set -e

if [ -z "$YT_URL" ] || [ -z "$TG_RTMP" ] || [ -z "$TG_KEY" ]; then
  echo "Missing env: YT_URL, TG_RTMP, TG_KEY"
  exit 1
fi

# Запускаем ffmpeg в фоне
(
  while true; do
    echo "Downloading video from $YT_URL..."
    yt-dlp -f "bestvideo+bestaudio" --merge-output-format mp4 -o video.mp4 "$YT_URL"
    
    if [ ! -f video.mp4 ]; then
      echo "Download failed. Retry in 10s..."
      sleep 10
      continue
    fi

    echo "Streaming video.mp4 -> rtmp://$TG_RTMP/$TG_KEY"

    ffmpeg -hide_banner -loglevel warning \
      -re -i video.mp4 \
      -vf "scale=1080:-2, pad=1080:1920:(ow-iw)/2:(oh-ih)/2, fps=${FPS}" \
      -c:v libx264 -preset "${X264_PRESET}" -b:v "${VIDEO_BITRATE}" -maxrate "${VIDEO_BITRATE}" -bufsize "$((2*${VIDEO_BITRATE%k}))k" \
      -c:a aac -b:a "${AUDIO_BITRATE}" -ar 44100 \
      -f flv "rtmp://$TG_RTMP/$TG_KEY"

    echo "FFmpeg exited. Reconnect in 5s..."
    sleep 5
  done
) &

# Минимальный HTTP-сервер для Render health check
python3 -m http.server 8080
