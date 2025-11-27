# Telegram Live Relay

Этот проект ретранслирует YouTube‑стрим в Telegram профиль/канал через Render.

## Переменные окружения
- `YT_URL` — ссылка на YouTube трансляцию
- `TG_RTMP` — RTMP сервер Telegram (выдаётся при создании эфира)
- `TG_KEY` — Stream Key из Telegram
- `VIDEO_BITRATE` — битрейт видео (например, 3000k)
- `AUDIO_BITRATE` — битрейт аудио (например, 128k)
- `FPS` — частота кадров (30 или 60)
- `X264_PRESET` — пресет кодека (veryfast, faster, medium)

