#!/bin/bash
set -e

# Список Dropbox ссылок (каждая с ?dl=1)
URLS=(
  "https://www.dropbox.com/scl/fi/0mv77533xk7bd603cjp9l/videoplayback.mp4?rlkey=s8rl59kao2s7gkgxyl7nmzhs6&st=dm1ba4pw&dl=1"
  "https://www.dropbox.com/scl/fi/ull7j5mnodq304xazz0ew/music.mp4?rlkey=2zkeaifcx1k730bwk0nq9ri9e&st=dvtllf90&dl=1"
)

FILES=()

# Скачиваем все файлы
for URL in "${URLS[@]}"; do
  NAME=$(basename "$URL" | cut -d'?' -f1)   # имя файла
  wget --progress=dot:mega -O "$NAME" "$URL"
  FILES+=("$NAME")
done

echo "Все файлы скачаны: ${FILES[@]}"

python3 -m http.server 8080 &  # health-check для Render

# Цикл стрима: проигрываем по очереди все файлы
while true; do
  for FILE in "${FILES[@]}"; do
    ffmpeg -hide_banner -loglevel warning \
      -re -i "$FILE" \
      -vf "scale=640:-2, fps=20" \
      -c:v libx264 -preset ultrafast -b:v 600k -maxrate 600k -bufsize 2000k \
      -c:a aac -b:a 64k -ar 44100 \
      -f flv "$TG_RTMP/$TG_KEY"
  done
done
