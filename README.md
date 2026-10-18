# MangoHud · RivaTuner Pro

Overlay para [MangoHud](https://github.com/flightlessmango/MangoHud) con estética "RivaTuner Pro":
FPS protagonista, gráfica de frametime, bloques GPU / CPU con los **colores de tu marca**
(NVIDIA · AMD · Intel), gráficas de área de carga, aviso de throttling y métricas
AVG / 1 % low / 0.1 % low.

## Instalación en un comando

```bash
git clone https://github.com/Callejasto/mangohud-rivatuner-pro.git
cd mangohud-rivatuner-pro
bash instalar.sh
```

El instalador:

1. Instala MangoHud si falta (apt · pacman · dnf · zypper, y la extensión para Steam Flatpak).
2. Detecta la marca de tu **GPU** y **CPU** y aplica sus colores.
3. Detecta la **resolución** del monitor y ajusta el tamaño del overlay (1080p / 1440p / 4K).
4. Escribe `~/.config/MangoHud/MangoHud.conf` (hace copia de seguridad si ya tenías uno).

Para activarlo en **todos** los juegos sin tocar cada uno:

```bash
bash instalar.sh --global
```

## Usarlo

| Dónde | Cómo |
|---|---|
| Steam | Propiedades del juego → Opciones de lanzamiento → `mangohud %command%` |
| Terminal | `mangohud ./juego` |
| Lutris / Heroic | Casilla "MangoHud" |
| Probar ya | `mangohud glxgears` o `mangohud vkcube` |

Atajos: **Shift derecha + F12** muestra/oculta · **Shift izquierda + F1** alterna el límite de FPS.

## Qué muestra

```
┌─────────────────────────────────────┐
│ 165 FPS            Vulkan · Mailbox │  ← color por rango (rojo <60 · ámbar <120 · verde)
│ ~~~~~~~~ frametime ~~~~~~~~~~~~~~~ │
├─────────────────────────────────────┤
│ AMD GPU   RX 7900 XTX               │  ← bloque en el color de la GPU
│ 62°C  78%  2650 MHz  285 W  VRAM    │     + hotspot, fan, voltaje, throttling
├─────────────────────────────────────┤
│ INTEL CPU i9-14900K                 │  ← bloque en el color de la CPU
│ 48°C  52%  5200 MHz  95 W           │
├─────────────────────────────────────┤
│ RAM · swap · E/S disco              │
│ ▁▂▃▅▆ carga GPU   ▁▂▃ carga CPU     │  ← gráficas de área
│ AVG 162 · 1% low 128 · 0.1% low 94  │
└─────────────────────────────────────┘
```

## Configs listas por combinación

Si prefieres copiar a mano en vez de usar el instalador:

```
MangoHud_AMD-GPU_Intel-CPU.conf
MangoHud_AMD-GPU_AMD-CPU.conf
MangoHud_NVIDIA-GPU_Intel-CPU.conf
MangoHud_NVIDIA-GPU_AMD-CPU.conf
MangoHud_Intel-GPU_Intel-CPU.conf
MangoHud_Intel-GPU_AMD-CPU.conf
```

```bash
cp MangoHud_AMD-GPU_Intel-CPU.conf ~/.config/MangoHud/MangoHud.conf
```

Tamaño por resolución (si copias a mano): `font_size` / `width` → 1080p `20/280`, 1440p `24/330`, 4K `36/480`.

## Config por juego

Un archivo con el nombre del ejecutable manda sobre el global:

```
~/.config/MangoHud/cyberpunk2077.exe.conf
~/.config/MangoHud/cs2.conf
```

## Limitaciones (de MangoHud, no de esta config)

- **No detecta DLSS / FSR / XeSS ni Frame Generation**: esa información solo la expone el driver o el juego.
  `fsr` muestra estado y sharpness de FSR bajo gamescope; `custom_text` deja una etiqueta fija editable.
- **No separa FPS reales de generados** con Frame Gen activo.
- **No se auto-escala** en caliente; el instalador fija el tamaño según tu monitor al ejecutarse.

## Personalizar

- Quitar algo: comenta la línea con `#`.
- Reordenar: con `legacy_layout=0` el orden del archivo es el orden en pantalla.
- Compacto: añade `hud_compact`. Una sola fila arriba: añade `horizontal`.
- Todos los parámetros: `mangohud --help` · `man mangohud`.

## Licencia

MIT
