#!/usr/bin/env bash

# --- Настройки ---
WALLPAPER_DIR="$HOME/.config/hypr/wallpapers"
CONFIG_FILE="$HOME/.config/hypr/hyprpaper.conf"
FIT_MODE="fill" # Можно изменить на cover, contain, tile

# --- Функция: получить случайное изображение из папки ---
get_random_wallpaper() {
    local selected_file
    # Ищем все популярные форматы изображений
    selected_file=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.bmp" -o -iname "*.webp" \) | shuf -n 1)
    
    if [[ -z "$selected_file" ]]; then
        echo "Ошибка: Не найдено изображений в $WALLPAPER_DIR" >&2
        exit 1
    fi
    echo "$selected_file"
}

# --- Получаем список мониторов ---
# Используем hyprctl для получения имен в формате JSON, парсим через jq
if ! command -v jq &> /dev/null; then
    echo "Ошибка: Утилита 'jq' не установлена. Установите её (например, 'sudo pacman -S jq')." >&2
    exit 1
fi

mapfile -t MONITORS < <(hyprctl monitors -j | jq -r '.[].name')

if [ ${#MONITORS[@]} -eq 0 ]; then
    echo "Ошибка: Не удалось получить список мониторов." >&2
    exit 1
fi

# --- Генерируем новый hyprpaper.conf ---
# Очищаем файл и добавляем заголовок (опционально)
echo "# Конфиг сгенерирован автоматически $(date)" > "$CONFIG_FILE"
echo "# Для каждого монитора выбрано случайное изображение." >> "$CONFIG_FILE"
echo "" >> "$CONFIG_FILE"

# Для каждого монитора выбираем случайную картинку и добавляем в конфиг
for monitor in "${MONITORS[@]}"; do
    wallpaper_path=$(get_random_wallpaper)
    echo "preload = $wallpaper_path" >> "$CONFIG_FILE"
    echo "wallpaper { 
    monitor = $monitor 
    path = $wallpaper_path 
    fit_mode = $FIT_MODE 
    }" >> "$CONFIG_FILE"
    echo "" >> "$CONFIG_FILE"
done

# Добавляем правило-запасное (fallback) на случай, если какой-то монитор не получил обои
# Это необязательно, но повышает надежность.
fallback_wallpaper=$(get_random_wallpaper)
echo "# Fallback правило на случай, если какой-то монитор пропущен" >> "$CONFIG_FILE"
echo "preload = $fallback_wallpaper" >> "$CONFIG_FILE"
echo "wallpaper { 
monitor = 
path = $fallback_wallpaper 
fit_mode = $FIT_MODE 
}" >> "$CONFIG_FILE"

echo "✅ Конфиг hyprpaper успешно обновлен: $CONFIG_FILE"