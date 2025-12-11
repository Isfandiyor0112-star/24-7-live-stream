FROM debian:stable-slim

RUN apt-get update && apt-get install -y ffmpeg python3 && rm -rf /var/lib/apt/lists/*

COPY . /app
WORKDIR /app

CMD ["bash", "start.sh"]