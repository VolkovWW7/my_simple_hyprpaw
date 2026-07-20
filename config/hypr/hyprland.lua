-- =========================================================================
-- 1. МОНИТОРЫ И NVIDIA
-- =========================================================================

hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1,
})

--для определения доступных мониторов и режима работы введите в коммандной строке
--                     hyprctl monitors
--hl.monitor({
--    output   = "DP-3",
--    mode     = "1920x1080@170",
--    position = "1920x0", --устангавливает монитор справо от основного
--    scale    = 1,
--})

-- Автоопределение видеокарты по PCI vendor ID из /sys/class/drm — без внешних
-- утилит вроде lspci и без запуска процессов, работает на любой машине "из коробки".
local function detect_gpu_vendor()
    local vendor_ids = {
        ["0x10de"] = "nvidia",
        ["0x1002"] = "amd",
        ["0x8086"] = "intel",
    }
    for i = 0, 9 do
        local f = io.open("/sys/class/drm/card" .. i .. "/device/vendor", "r")
        if f then
            local id = f:read("*l")
            f:close()
            if id and vendor_ids[id] then
                return vendor_ids[id]
            end
        end
    end
    return "unknown"
end
 
local gpu = detect_gpu_vendor()
-- Если на конкретной машине автоопределение ошиблось (например, гибридная
-- Intel+NVIDIA-графика и подхватилась не та карта) — можно задать вручную:
-- local gpu = "nvidia"
 

hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("GDK_BACKEND", "wayland,x11")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("XCURSOR_THEME", "Breeze")
hl.env("XCURSOR_SIZE", 24)
hl.env("XDG_MENU_PREFIX", "arch-")

hl.config({
    cursor = {
        no_hardware_cursors = true,
    },
})

hl.config({
    xwayland = {
        force_zero_scaling = true,
    },
})

-- =========================================================================
-- 2. КЛАВИАТУРА / МЫШЬ
-- =========================================================================

hl.config({
    input = {
        kb_layout = "us,ru",
        kb_options = "grp:alt_shift_toggle",
        follow_mouse = 1,
        sensitivity = 0,
        touchpad = {
            natural_scroll = true,
        },
    },
})

-- =========================================================================
-- 3. ВИЗУАЛ
-- =========================================================================

hl.config({
    general = {
        gaps_in = 4,
        gaps_out = 8,
        border_size = 2,
        layout = "dwindle",
        resize_on_border = true,
        col = {
            active_border = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
          inactive_border = "rgba(595959aa)",
        },
    },
})

hl.config({
    decoration = {
        rounding = 8,
        blur = {
            enabled = true,
            size = 1,
            passes = 1,
        },
    },
})

hl.config({
    animations = {
        enabled = true,
    },
})

-- =========================================================================
-- 4. ХОТКЕИ
-- =========================================================================

local mainMod = "SUPER"

hl.bind(mainMod .. " + SHIFT + M", hl.dsp.exit(), { description = "Выйти из Hyprland" })
hl.bind("CTRL + ALT" .. " + " .. "T", hl.dsp.exec_cmd("konsole"), { description = "Открыть терминал" })
hl.bind(mainMod .. " + " .. "E", hl.dsp.exec_cmd("dolphin"), { description = "Открыть Dolphin" })
hl.bind("ALT" .. " + " .. "F4", { description = "Закрыть окно" })
hl.bind(mainMod .. "+" .. "Q", hl.dsp.window.close(), { description = "Закрыть окно" })
hl.bind(mainMod .. " + " .. "Space", hl.dsp.window.float({ action = "toggle" }), { description = "Плавающее окно" })
hl.bind(mainMod .. " + " .. "D", hl.dsp.exec_cmd("wofi --show drun"), { description = "Лаунчер приложений" })
hl.bind(mainMod .. " + " .. "C", hl.dsp.exec_cmd("kate"), { description = "Открыть Kate" })
hl.bind("SHIFT + Print", hl.dsp.exec_cmd("grim ~/storage/Изображения/'Снимки экрана'/Screenshot_$(date +%Y-%m-%d_%H-%M-%S).png"), { description = "Скриншот всего экрана" })
hl.bind("Print", hl.dsp.exec_cmd("grim -g \"$(slurp)\" - | wl-copy"), { description = "Скриншот" })
hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "S", hl.dsp.exec_cmd("spectacle -r -c"), { description = "Скриншот области в буфер" })
hl.bind(mainMod .. " + " .. "B", hl.dsp.exec_cmd( "firefox" ), { description = "Открыть браузер" })

-- Фокус между окнами
hl.bind(mainMod .. " + " .. "left", hl.dsp.focus({ direction = "left" }), { description = "Фокус: окно слева" })
hl.bind(mainMod .. " + " .. "right", hl.dsp.focus({ direction = "right" }), { description = "Фокус: окно справа" })
hl.bind(mainMod .. " + " .. "up", hl.dsp.focus({ direction = "up" }), { description = "Фокус: окно сверху" })
hl.bind(mainMod .. " + " .. "down", hl.dsp.focus({ direction = "down" }), { description = "Фокус: окно снизу" })

-- Рабочие столы
hl.bind(mainMod .. " + " .. "1", hl.dsp.focus({ workspace = 1 }), { description = "Рабочий стол 1" })
hl.bind(mainMod .. " + " .. "2", hl.dsp.focus({ workspace = 2 }), { description = "Рабочий стол 2" })
hl.bind(mainMod .. " + " .. "3", hl.dsp.focus({ workspace = 3 }), { description = "Рабочий стол 3" })
hl.bind(mainMod .. " + " .. "4", hl.dsp.focus({ workspace = 4 }), { description = "Рабочий стол 4" })

hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "1", hl.dsp.window.move({ workspace = 1 }), { description = "Окно -> раб.стол 1" })
hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "2", hl.dsp.window.move({ workspace = 2 }), { description = "Окно -> раб.стол 2" })
hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "3", hl.dsp.window.move({ workspace = 3 }), { description = "Окно -> раб.стол 3" })
hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "4", hl.dsp.window.move({ workspace = 4 }), { description = "Окно -> раб.стол 4" })

-- Перенос окна на другой монитор (проверить работоспособность перед использованием!)
hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "right", hl.dsp.window.move({ monitor = "r" }), { description = "Окно -> монитор справа" })
hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "left", hl.dsp.window.move({ monitor = "l" }), { description = "Окно -> монитор слева" })
hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "up", hl.dsp.window.move({ monitor = "u" }), { description = "Окно -> монитор сверху" })
hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "down", hl.dsp.window.move({ monitor = "d" }), { description = "Окно -> монитор снизу" })

hl.bind(mainMod .. " + " .. "Escape", hl.dsp.exec_cmd("wlogout"), { description = "Меню выхода" })
hl.bind(mainMod .. " + " .. "slash", hl.dsp.exec_cmd("~/.config/hypr/scripts/keybinds.sh"), { description = "Шпаргалка по хоткеям" })

hl.bind(mainMod .. " + " .. "mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + " .. "mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })

-- =========================================================================
-- 5. ПРАВИЛА ОКОН
-- =========================================================================

hl.window_rule({ match = { class = "^(pavucontrol)$" }, float = true })
hl.window_rule({ match = { class = "^(nm-connection-editor)$" }, float = true })

-- Центрируем ЛЮБОЕ плавающее окно при открытии: диалоги выбора файла, всплывающие
-- окна Steam, Dolphin в плавающем режиме и т.п. 
hl.window_rule({ match = { class = ".*" }, center = true })

-- =========================================================================
-- 6. АВТОЗАПУСК
-- =========================================================================

hl.on("hyprland.start", function()
    hl.exec_cmd("/usr/lib/polkit-kde-authentication-agent-1")
    hl.exec_cmd("kdeinit6")
    hl.exec_cmd("waybar")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("nm-applet --indicator")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("telegram-desktop -startintray")
    hl.exec_cmd("systemctl --user start xdg-desktop-portal xdg-desktop-portal-hyprland")
    hl.exec_cmd("blueman-applet")
    hl.exec_cmd("steam -silent")
    hl.exec_cmd("hiddify")
end)
