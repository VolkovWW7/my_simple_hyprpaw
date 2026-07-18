#!/bin/bash

# 1. Закрываем тяжелые приложения, которые используют NVIDIA/XWayland
killall -9 telegram-desktop steam hiddify firefox konsole dolphin kate spectacle 2>/dev/null

# 2. Убиваем панели, обои и буфер обмена
killall -9 waybar hyprpaper nm-applet blueman-applet wl-paste 2>/dev/null

# 3. Чистим порталы и агенты аутентификации
killall -9 xdg-desktop-portal-hyprland xdg-desktop-portal polkit-kde-authentication-agent-1 2>/dev/null

# Небольшая пауза, чтобы драйвер NVIDIA успел освободить видеопамять
sleep 0.2

# 4. Завершаем сессию Hyprland
hyprctl eval "hl.dispatch(hl.dsp.exit())"
