#!/usr/bin/env bash
# ============================================================================
#  Instalador MangoHud "RivaTuner Pro"
#  - Instala MangoHud (apt / pacman / dnf / zypper / Flatpak si aplica)
#  - Detecta marca de GPU y CPU y aplica sus colores
#  - Ajusta el tamaño del overlay a la resolución del monitor
#  - Escribe ~/.config/MangoHud/MangoHud.conf
#  Uso:  bash instalar.sh            (interactivo mínimo)
#        bash instalar.sh --global   (además lo activa en TODOS los juegos)
# ============================================================================
set -euo pipefail

GLOBAL=0
[[ "${1:-}" == "--global" ]] && GLOBAL=1

c()  { printf '\033[1;36m%s\033[0m\n' "$*"; }
ok() { printf '\033[1;32m✔ %s\033[0m\n' "$*"; }
wr() { printf '\033[1;33m! %s\033[0m\n' "$*"; }

# ---------- 1. Instalar MangoHud ----------
c "1/4  Comprobando MangoHud..."
if command -v mangohud >/dev/null 2>&1; then
    ok "MangoHud ya está instalado ($(mangohud --version 2>/dev/null | head -1 || echo 'versión desconocida'))"
else
    if   command -v pacman  >/dev/null; then sudo pacman -S --needed --noconfirm mangohud lib32-mangohud
    elif command -v apt     >/dev/null; then sudo apt update && sudo apt install -y mangohud
    elif command -v dnf     >/dev/null; then sudo dnf install -y mangohud
    elif command -v zypper  >/dev/null; then sudo zypper install -y mangohud
    else wr "No reconozco tu gestor de paquetes. Instala 'mangohud' a mano y vuelve a ejecutar."; exit 1
    fi
    ok "MangoHud instalado"
fi
# Steam en Flatpak necesita la extensión
if command -v flatpak >/dev/null && flatpak list 2>/dev/null | grep -q com.valvesoftware.Steam; then
    flatpak install -y --noninteractive flathub org.freedesktop.Platform.VulkanLayer.MangoHud 2>/dev/null \
        && ok "Extensión MangoHud para Steam Flatpak instalada" || true
fi

# ---------- 2. Detectar hardware ----------
c "2/4  Detectando hardware..."
GPU_LINE=$(lspci 2>/dev/null | grep -Ei 'vga|3d|display' | head -1 || true)
case "$GPU_LINE" in
    *NVIDIA*|*nVidia*)             GPU=NVIDIA ;;
    *AMD*|*ATI*|*Radeon*)          GPU=AMD ;;
    *Intel*)                       GPU=Intel ;;
    *)                             GPU=AMD; wr "No pude detectar la GPU, asumo AMD (edítalo luego en el .conf)";;
esac
CPU_VENDOR=$(grep -m1 'vendor_id' /proc/cpuinfo | awk '{print $3}')
case "$CPU_VENDOR" in
    GenuineIntel) CPU=Intel ;;
    AuthenticAMD) CPU=AMD ;;
    *)            CPU=Intel; wr "No pude detectar la CPU, asumo Intel";;
esac
GPU_MODEL=$(echo "$GPU_LINE" | sed -E 's/.*: //; s/\(rev.*//' | cut -c1-60)
CPU_MODEL=$(grep -m1 'model name' /proc/cpuinfo | sed 's/.*: //' | cut -c1-60)
ok "GPU: $GPU  ($GPU_MODEL)"
ok "CPU: $CPU  ($CPU_MODEL)"

# ---------- 3. Resolución -> tamaño ----------
c "3/4  Ajustando tamaño a la pantalla..."
H=0
if command -v xrandr >/dev/null && [[ -n "${DISPLAY:-}" ]]; then
    H=$(xrandr --current 2>/dev/null | grep -oP '\d+x\K\d+(?=\s+\d+\.\d+\*)' | sort -n | tail -1 || echo 0)
fi
if [[ "$H" -eq 0 ]]; then
    # Wayland / sin X: leer el modo del primer conector activo
    for f in /sys/class/drm/card*-*/modes; do
        [[ -r "$f" ]] && H=$(head -1 "$f" | cut -dx -f2) && [[ -n "$H" ]] && break
    done
fi
H=${H:-1440}
if   (( H >= 2000 )); then FONT=36; WIDTH=480; RES="4K"
elif (( H >= 1300 )); then FONT=24; WIDTH=330; RES="1440p"
else                        FONT=20; WIDTH=280; RES="1080p"
fi
ok "Resolución detectada: ${H}p (${RES}) -> font_size=$FONT width=$WIDTH"

# ---------- Colores por marca ----------
color_main()  { case "$1" in NVIDIA) echo 76B900;; AMD) echo ED1C24;; Intel) echo 0071C5;; esac; }
color_light() { case "$1" in NVIDIA) echo A8FF00;; AMD) echo FF6B6B;; Intel) echo 60B5FF;; esac; }
upscaler()    { case "$1" in NVIDIA) echo "DLSS 3.5 / DLSS FG";; AMD) echo "FSR 3.1 / AFMF 2";; Intel) echo "XeSS 2 / XeSS FG";; esac; }
GPU_MAIN=$(color_main "$GPU"); GPU_LIGHT=$(color_light "$GPU"); CPU_MAIN=$(color_main "$CPU"); UPS=$(upscaler "$GPU")

# ---------- 4. Escribir configuración ----------
c "4/4  Escribiendo configuración..."
DEST="$HOME/.config/MangoHud"
mkdir -p "$DEST"
[[ -f "$DEST/MangoHud.conf" ]] && cp "$DEST/MangoHud.conf" "$DEST/MangoHud.conf.bak.$(date +%s)" && ok "Copia de seguridad de tu config anterior"

cat > "$DEST/MangoHud.conf" <<EOF
################################################################################
#  MangoHud — Overlay "RivaTuner Pro"   ·   $GPU GPU + $CPU CPU   ·   $RES
#  Generado automáticamente. Edita lo que quieras; # comenta una línea.
#  Shift derecha + F12 = mostrar/ocultar
################################################################################

### Diseño
legacy_layout=0
position=top-right
offset_x=12
offset_y=12
round_corners=10
width=$WIDTH
table_columns=3
background_alpha=0.55
background_color=0E121C
text_outline=1
text_outline_color=000000
text_outline_thickness=1.2
font_size=$FONT
toggle_hud=Shift_R+F12
toggle_fps_limit=Shift_L+F1
fps_sampling_period=250

### FPS + frametime
fps
fps_color_change
fps_value=60,120
fps_color=FF5252,FFB84D,4ADE80
show_fps_limit
engine_version
engine_color=$GPU_LIGHT
present_mode
frame_timing=1
frametime_color=60A5FA

### GPU ($GPU)
gpu_name
gpu_text=$GPU GPU
gpu_color=$GPU_MAIN
gpu_stats
gpu_temp
gpu_junction_temp
gpu_core_clock
gpu_mem_clock
gpu_power
gpu_voltage
gpu_fan
gpu_load_change
gpu_load_value=60,90
gpu_load_color=4ADE80,FBBF24,EF4444
vram
vram_color=$GPU_LIGHT
throttling_status

### CPU ($CPU)
cpu_text=$CPU CPU
cpu_color=$CPU_MAIN
cpu_stats
cpu_temp
cpu_power
cpu_mhz
cpu_load_change
cpu_load_value=60,90
cpu_load_color=4ADE80,FBBF24,EF4444

### Sistema
ram
ram_color=CBD5E1
swap
io_read
io_write
io_color=94A3B8

### Gráficas de área (carga GPU / CPU)
graphs=gpu_load,cpu_load

### Pie: AVG · 1% low · 0.1% low
fps_metrics=avg,0.01,0.001

### Upscaler (MangoHud no detecta DLSS/FSR/XeSS ni Frame Gen; etiqueta fija editable)
custom_text=$UPS
fsr
refresh_rate

### Extras
gamemode
vkbasalt
wine
wine_color=CBD5E1
EOF
ok "Config escrita en $DEST/MangoHud.conf"

# ---------- Activación global opcional ----------
if (( GLOBAL )); then
    mkdir -p "$HOME/.config/environment.d"
    echo "MANGOHUD=1" > "$HOME/.config/environment.d/mangohud.conf"
    grep -q 'MANGOHUD=1' "$HOME/.profile" 2>/dev/null || echo 'export MANGOHUD=1' >> "$HOME/.profile"
    ok "MangoHud activado para todos los juegos (aplica al reiniciar sesión)"
fi

echo
c "Listo. Cómo usarlo:"
echo "  • Steam -> Propiedades del juego -> Opciones de lanzamiento:   mangohud %command%"
echo "  • Terminal:                                                  mangohud ./juego"
echo "  • Lutris / Heroic: activa la casilla MangoHud"
(( GLOBAL )) || echo "  • Para activarlo en TODO sin tocar cada juego:  bash instalar.sh --global"
echo "  • Probar ahora mismo:                                         mangohud glxgears   (o vkcube)"
