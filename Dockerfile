FROM ubuntu:22.04

# Установка ffmpeg и yt-dlp
RUN apt-get update && apt-get install -y \
    ffmpeg python3 python3-pip curl ca-certificates && \
    pip3 install yt-dlp && \
    rm -rf /var/lib/apt/lists/*

# Копируем стартовый скрипт
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Переменные окружения (будем задавать в Render)
ENV YT_URL=""
ENV TG_RTMP=""
ENV TG_KEY=""
ENV VIDEO_BITRATE="3000k"
ENV AUDIO_BITRATE="128k"
ENV FPS="30"
ENV X264_PRESET="veryfast"

CMD ["/start.sh"]
