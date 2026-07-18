#!/bin/bash
# Показывает хоткеи (комбинация + описание) через wofi.
# Требует, чтобы бинды в hyprland.lua имели { description = "..." }

hyprctl binds -j | jq -r '
  .[] |
  select(.description != null and .description != "") |
  (.modmask) as $m |
  (
    (if (($m / 64 | floor) % 2 == 1) then "SUPER+" else "" end) +
    (if (($m / 8  | floor) % 2 == 1) then "ALT+"   else "" end) +
    (if (($m / 4  | floor) % 2 == 1) then "CTRL+"  else "" end) +
    (if (($m / 1  | floor) % 2 == 1) then "SHIFT+" else "" end)
  ) as $mods |
  "\($mods)\(.key)  →  \(.description)"
' | wofi --dmenu --prompt "Горячие клавиши" --width 700 --height 500

