#!/bin/bash
set -e

URL="https://www.dropbox.com/scl/fi/ull7j5mnodq304xazz0ew/music.mp4?rlkey=2zkeaifcx1k730bwk0nq9ri9e&st=ga5rkro9&dl=1"
FILE="music.mp4"

echo "Downloading $FILE from Dropbox..."
# Показываем прогресс в процентах
curl -L --progress-bar "$URL" -o "$FILE"

echo "Download finished. Starting stream..."

if [ -z "$TG_RTMP" ] || [ -z "$TG_KEY" ]; then
  echo "Missing env: TG_RTMP, TG_KEY"
  exit 1
fi

while true; do
  ffmpeg -hide_banner -loglevel warning \
    -re -stream_loop -1 -i "$FILE" \
    -vf "scale=720:-2, pad=720:1280:(ow-iw)/2:(oh-ih)/2, fps=25" \
    -c:v libx264 -preset ultrafast -b:v 800k -maxrate 800k -bufsize 1600k \
    -c:a aac -b:a 96k -ar 44100 \
    -f flv "$TG_RTMP/$TG_KEY"

  echo "FFmpeg exited. Reconnect in 5s..."
  sleep 5
done
