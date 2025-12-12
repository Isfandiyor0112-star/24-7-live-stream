#!/bin/bash
set -e

URL="https://www.dropbox.com/scl/fi/ull7j5mnodq304xazz0ew/music.mp4?rlkey=2zkeaifcx1k730bwk0nq9ri9e&st=ga5rkro9&dl=1"
FILE="music.mp4"

echo "Downloading $FILE from Dropbox..."
wget --progress=dot:mega -O "$FILE" "$URL"

echo "Download finished. Starting stream..."

if [ -z "$TG_RTMP" ] || [ -z "$TG_KEY" ]; then
  echo "Missing env: TG_RTMP, TG_KEY"
  exit 1
fi

# Запускаем фиктивный HTTP‑сервер для Render health‑check
python3 -m http.server 8080 &

# Основной цикл стрима
while true; do
  ffmpeg -hide_banner -loglevel warning \
    -re -stream_loop -1 -i "$FILE" \
    -vf "scale=640:-2, pad=640:960:(ow-iw)/2:(oh-ih)/2, fps=20" \
    -c:v libx264 -preset ultrafast -b:v 600k -maxrate 600k -bufsize 2000k \
    -c:a aac -b:a 64k -ar 44100 \
    -f flv "$TG_RTMP/$TG_KEY"

  echo "FFmpeg exited. Reconnect in 5s..."
  sleep 5
done
