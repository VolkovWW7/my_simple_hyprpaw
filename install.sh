#!/bin/bash
# install.sh — установка Hyprland-дотфайлов на новую машину.
# Копирует конфиги из этого репозитория в ~/.config, бэкапит то, что было раньше.

set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"
BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"

PKGS_PACMAN=(
    # Ядро Hyprland-окружения
    hyprland hypridle hyprlock hyprpaper waybar wofi
    # Используются в скриптах scripts/*.sh и keybinds.sh
    playerctl jq
    # Скриншоты (grim+slurp) и буфер обмена
    grim slurp wl-clipboard cliphist
    # Приложения, забинженные на конкретные хоткеи в hyprland.lua
    dolphin kate konsole
    # Сеть и Bluetooth: автозапуск nm-applet/blueman-applet + клик в waybar (nm-connection-editor)
    network-manager-applet blueman
    # Громкость (wpctl на хоткеях) и звук (pavucontrol по клику в waybar)
    wireplumber pavucontrol
    # Аутентификация и Wayland-порталы — без них часть автозапуска в hyprland.lua не отработает
    polkit-kde-agent kinit xdg-desktop-portal xdg-desktop-portal-hyprland
    # Шрифт для waybar/wofi/hyprlock/konsole
    ttf-jetbrains-mono
)

# wlogout в официальных репозиториях Arch отсутствует, только в AUR
PKGS_AUR=(wlogout)

info()  { echo -e "\033[1;36m==>\033[0m $1"; }
warn()  { echo -e "\033[1;33m!!\033[0m $1"; }

# -------------------------------------------------------------------------
# 1. Зависимости
# -------------------------------------------------------------------------
install_deps() {
    if command -v pacman &>/dev/null; then
        info "Обнаружен pacman — устанавливаю пакеты"
        sudo pacman -S --needed "${PKGS_PACMAN[@]}"
        install_aur_deps
    elif command -v apt &>/dev/null; then
        warn "Обнаружен apt. Список пакетов рассчитан на Arch — названия пакетов могут"
        warn "отличаться (hyprland/hypridle/hyprlock/hyprpaper в Debian/Ubuntu обычно"
        warn "нужно ставить из стороннего репозитория или собирать вручную)."
        if sudo apt install "${PKGS_PACMAN[@]}"; then
            info "Пакеты установлены"
        else
            read -rp "Продолжить установку без автоустановки зависимостей? [y/N] " ans
            [[ "$ans" =~ ^[Yy]$ ]] || exit 1
        fi
    else
        warn "Пакетный менеджер не распознан. Установите вручную: ${PKGS_PACMAN[*]} ${PKGS_AUR[*]}"
        read -rp "Продолжить без автоустановки зависимостей? [y/N] " ans
        [[ "$ans" =~ ^[Yy]$ ]] || exit 1
    fi
}

# wlogout официально в pacman не входит — ставим через AUR-хелпер, если он есть
install_aur_deps() {
    local helper="" flag="-S"
    if command -v yay &>/dev/null; then
        helper="yay"
    elif command -v paru &>/dev/null; then
        helper="paru"
    elif command -v aura &>/dev/null; then
        helper="aura"
        flag="-A"   # у aura именно этот флаг ставит пакеты из AUR, -S не подойдёт
    fi

    if [ -n "$helper" ]; then
        info "Обнаружен $helper — ставлю из AUR: ${PKGS_AUR[*]}"
        "$helper" "$flag" --needed --noconfirm "${PKGS_AUR[@]}"
    else
        warn "AUR-хелпер (yay/paru/aura) не найден. wlogout нужно поставить вручную:"
        warn "  git clone https://aur.archlinux.org/wlogout.git && cd wlogout && makepkg -si"
        warn "или установите yay/paru/aura и перезапустите install.sh"
    fi
}

# -------------------------------------------------------------------------
# 2. Копирование конфигов (с бэкапом того, что уже есть)
# -------------------------------------------------------------------------
copy_config() {
    local src="$1" dest="$2"
    if [ -e "$dest" ] || [ -L "$dest" ]; then
        mkdir -p "$BACKUP_DIR"
        mv "$dest" "$BACKUP_DIR/$(basename "$dest")"
        info "Бэкап существующего конфига: $dest -> $BACKUP_DIR/"
    fi
    mkdir -p "$(dirname "$dest")"
    cp -r "$src" "$dest"
    info "Скопировано: $src -> $dest"
}

cp_configs() {
    copy_config "$REPO_DIR/config/hypr"    "$CONFIG_DIR/hypr"
    copy_config "$REPO_DIR/config/waybar"  "$CONFIG_DIR/waybar"
    copy_config "$REPO_DIR/config/wofi"    "$CONFIG_DIR/wofi"
    copy_config "$REPO_DIR/config/wlogout" "$CONFIG_DIR/wlogout"
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
    cp_configs
    fix_permissions
    install_konsole_profile
    info "Готово! Перелогиньтесь в сессию Hyprland, чтобы применились все изменения."
}

main "$@"