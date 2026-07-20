#!/bin/bash
# dpms-off-if-idle.sh
# Выключает экран (DPMS off), но откладывает выключение,
# пока где-то играет медиа (аудио/видео через MPRIS).
# Требует пакет playerctl.

while playerctl status 2>/dev/null | grep -q "Playing"; do
    sleep 30
done

hyprctl dispatch dpms off
