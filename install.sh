#!/bin/bash
# install.sh — установка Hyprland-дотфайлов на новую машину.
# Создаёт симлинки из этого репозитория в ~/.config, бэкапит то, что было раньше.

set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"
BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"

PKGS_PACMAN=(
    hyprland hypridle hyprlock hyprpaper
    waybar wofi wlogout
    playerctl jq grim slurp wl-clipboard cliphist
    kitty dolphin kate spectacle konsole
    network-manager-applet blueman
    ttf-jetbrains-mono
)

info()  { echo -e "\033[1;36m==>\033[0m $1"; }
warn()  { echo -e "\033[1;33m!!\033[0m $1"; }

# -------------------------------------------------------------------------
# 1. Зависимости
# -------------------------------------------------------------------------
install_deps() {
    if command -v pacman &>/dev/null; then
        info "Обнаружен pacman — устанавливаю пакеты"
        sudo pacman -S --needed --noconfirm "${PKGS_PACMAN[@]}"
    elif command -v apt &>/dev/null; then
        warn "Обнаружен apt. Список пакетов рассчитан на Arch — названия пакетов могут"
        warn "отличаться (hyprland/hypridle/hyprlock/hyprpaper в Debian/Ubuntu обычно"
        warn "нужно ставить из стороннего репозитория или собирать вручную)."
        read -rp "Продолжить установку без автоустановки зависимостей? [y/N] " ans
        [[ "$ans" =~ ^[Yy]$ ]] || exit 1
    else
        warn "Пакетный менеджер не распознан. Установите вручную: ${PKGS_PACMAN[*]}"
        read -rp "Продолжить без автоустановки зависимостей? [y/N] " ans
        [[ "$ans" =~ ^[Yy]$ ]] || exit 1
    fi
}

# -------------------------------------------------------------------------
# 2. Симлинки конфигов (с бэкапом того, что уже есть)
# -------------------------------------------------------------------------
link_dir() {
    local src="$1" dest="$2"
    if [ -e "$dest" ] && [ ! -L "$dest" ]; then
        mkdir -p "$BACKUP_DIR"
        mv "$dest" "$BACKUP_DIR/$(basename "$dest")"
        info "Бэкап существующего конфига: $dest -> $BACKUP_DIR/"
    elif [ -L "$dest" ]; then
        rm "$dest"
    fi
    mkdir -p "$(dirname "$dest")"
    ln -s "$src" "$dest"
    info "Симлинк: $dest -> $src"
}

link_configs() {
    link_dir "$REPO_DIR/config/hypr"    "$CONFIG_DIR/hypr"
    link_dir "$REPO_DIR/config/waybar"  "$CONFIG_DIR/waybar"
    link_dir "$REPO_DIR/config/wofi"    "$CONFIG_DIR/wofi"
    link_dir "$REPO_DIR/config/wlogout" "$CONFIG_DIR/wlogout"
}

# -------------------------------------------------------------------------
# 3. Права на исполнение скриптов
# -------------------------------------------------------------------------
fix_permissions() {
    chmod +x "$REPO_DIR"/config/hypr/scripts/*.sh
    info "Скрипты в config/hypr/scripts сделаны исполняемыми"
}

# -------------------------------------------------------------------------
# 4. Шрифт для терминала (Konsole)
# -------------------------------------------------------------------------
install_konsole_profile() {
    if command -v konsole &>/dev/null; then
        mkdir -p "$HOME/.local/share/konsole"
        cp "$REPO_DIR/extras/JetBrainsMono.profile" "$HOME/.local/share/konsole/"
        info "Профиль Konsole с JetBrains Mono установлен."
        info "Активируйте его: Настройки Konsole -> Управление профилями -> JetBrainsMono -> По умолчанию"
    else
        warn "Konsole не найден, пропускаю установку профиля шрифта"
    fi
}

# -------------------------------------------------------------------------
main() {
    info "Установка Hyprland-дотфайлов из $REPO_DIR"
    install_deps
    link_configs
    fix_permissions
    install_konsole_profile
    info "Готово! Перелогиньтесь в сессию Hyprland, чтобы применились все изменения."
}

main "$@"
