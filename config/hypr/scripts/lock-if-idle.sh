#!/bin/bash
# lock-if-idle.sh
# Блокирует экран через hyprlock, но откладывает блокировку,
# пока где-то играет медиа (аудио/видео через MPRIS — Spotify, Firefox, mpv, VLC и т.д.)
# Требует пакет playerctl.

while playerctl status 2>/dev/null | grep -q "Playing"; do
    sleep 30
done

pidof hyprlock || hyprlock
