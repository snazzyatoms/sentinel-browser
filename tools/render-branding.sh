#!/usr/bin/env bash
# Render all Sentinel branding rasters from the SVG masters in tools/branding-src/.
# Requires: rsvg-convert (librsvg2-bin), python3 + pillow.
# Run inside WSL/Linux:  bash tools/render-branding.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$ROOT/tools/branding-src"
BRAND="$ROOT/themes/browser/branding/sentinel"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

# palettes: RIM_HI ACCENT RIM_LO IRIS_HI IRIS_LO
CYAN=("#7DD3FC" "#38BDF8" "#0E7490" "#A5F3FC" "#155E75")
VIOLET=("#C4B5FD" "#A78BFA" "#5B21B6" "#DDD6FE" "#4C1D95")

colorize() { # <in.svg> <out.svg> <palette...>
  local in="$1" out="$2"; shift 2
  local p=("$@")
  sed -e "s/RIM_HI/${p[0]}/g" -e "s/ACCENT/${p[1]}/g" -e "s/RIM_LO/${p[2]}/g" \
      -e "s/IRIS_HI/${p[3]}/g" -e "s/IRIS_LO/${p[4]}/g" "$in" > "$out"
}

render() { rsvg-convert -w "$2" -h "$2" "$1" -o "$3"; }

colorize "$SRC/logo.svg" "$WORK/logo-cyan.svg" "${CYAN[@]}"
colorize "$SRC/logo-small.svg" "$WORK/logo-small-cyan.svg" "${CYAN[@]}"
colorize "$SRC/logo.svg" "$WORK/logo-violet.svg" "${VIOLET[@]}"
colorize "$SRC/logo-small.svg" "$WORK/logo-small-violet.svg" "${VIOLET[@]}"

rlogo() { # <size> <variant>
  local master="logo-$2"; [ "$1" -le 32 ] && master="logo-small-$2"
  render "$WORK/$master.svg" "$1" "$WORK/logo-$2-$1.png"
}
for s in 16 22 24 32 48 64 70 128 150 192 256 270 384; do rlogo "$s" cyan; done
for s in 16 24 32 48 64 70 128 150 192 256 270 384; do rlogo "$s" violet; done

# document icons
for s in 16 24 32 48 64 128 256; do
  render "$SRC/file.svg" "$s" "$WORK/file-$s.png"
  render "$SRC/file_pdf.svg" "$s" "$WORK/filepdf-$s.png"
done
for s in 44 256; do render "$SRC/file_sentinel.svg" "$s" "$WORK/filesent-$s.png"; done

python3 - "$WORK" "$BRAND" "$ROOT" <<'PYEOF'
import os, struct, sys
from PIL import Image

WORK, BRAND, ROOT = sys.argv[1], sys.argv[2], sys.argv[3]

AVAIL = {"logo-cyan": [16,22,24,32,48,64,70,128,150,192,256,270,384],
         "logo-violet": [16,24,32,48,64,70,128,150,192,256,270,384],
         "file": [16,24,32,48,64,128,256],
         "filepdf": [16,24,32,48,64,128,256],
         "filesent": [44,256]}

def load(prefix, s):
    p = os.path.join(WORK, f"{prefix}-{s}.png")
    if not os.path.exists(p):
        bigger = min([a for a in AVAIL[prefix] if a >= s], default=max(AVAIL[prefix]))
        img = Image.open(os.path.join(WORK, f"{prefix}-{bigger}.png"))
        if bigger != s:
            img = img.resize((s, s), Image.LANCZOS)
        return img
    return Image.open(p)

def save(img, *rel):
    p = os.path.join(BRAND, *rel)
    os.makedirs(os.path.dirname(p), exist_ok=True)
    img.save(p)
    print("wrote", os.path.relpath(p, BRAND))

def write_ico(path, prefix, sizes):
    """ICO with per-size dedicated PNG renders embedded (Vista+ format)."""
    blobs = [(s, open(os.path.join(WORK, f"{prefix}-{s}.png"), "rb").read()) for s in sizes]
    out = struct.pack("<HHH", 0, 1, len(blobs))
    off = 6 + 16 * len(blobs)
    data = b""
    for s, blob in blobs:
        b = 0 if s == 256 else s
        out += struct.pack("<BBBBHHII", b, b, 0, 0, 1, 32, len(blob), off)
        data += blob; off += len(blob)
    with open(path, "wb") as f:
        f.write(out + data)
    print("wrote", os.path.basename(path))

NAVY = (10, 18, 38)

def on_bg(img, box):
    bg = Image.new("RGBA", box, NAVY + (255,))
    s = int(min(box) * 0.60)
    bg.alpha_composite(img.resize((s, s), Image.LANCZOS), ((box[0]-s)//2, (box[1]-s)//2))
    return bg

# --- default icon PNGs ---
for s in (16, 22, 24, 32, 48, 64, 128, 256):
    save(load("logo-cyan", s), f"default{s}.png")

# --- ICOs ---
S = [16, 24, 32, 48, 64, 128, 256]
write_ico(os.path.join(BRAND, "firefox.ico"), "logo-cyan", S)
write_ico(os.path.join(BRAND, "firefox64.ico"), "logo-cyan", S)
write_ico(os.path.join(BRAND, "newtab.ico"), "logo-cyan", S)
write_ico(os.path.join(BRAND, "newwindow.ico"), "logo-cyan", S)
write_ico(os.path.join(BRAND, "document.ico"), "file", S)
write_ico(os.path.join(BRAND, "document_pdf.ico"), "filepdf", S)
write_ico(os.path.join(BRAND, "pbmode.ico"), "logo-violet", S)

# --- private browsing PNGs ---
save(load("logo-violet", 70), "PrivateBrowsing_70.png")
save(load("logo-violet", 150), "PrivateBrowsing_150.png")

# --- about dialog ---
save(load("logo-cyan", 192), "content", "about-logo.png")
save(load("logo-cyan", 384), "content", "about-logo@2x.png")
save(load("logo-violet", 192), "content", "about-logo-private.png")
save(load("logo-violet", 384), "content", "about-logo-private@2x.png")
save(on_bg(load("logo-cyan", 256), (300, 236)).convert("RGB"), "content", "about.png")

# --- Windows tiles ---
save(load("logo-cyan", 70), "VisualElements_70.png")
save(load("logo-cyan", 150), "VisualElements_150.png")

# --- installer graphics ---
save(on_bg(load("logo-cyan", 256), (512, 320)).convert("P", palette=Image.ADAPTIVE), "background.png")
save(on_bg(load("logo-cyan", 256), (672, 411)).convert("L"), "bgstub.jpg")
save(on_bg(load("logo-cyan", 256), (1344, 822)).convert("L"), "bgstub_2x.jpg")
save(on_bg(load("logo-cyan", 128), (150, 57)).convert("RGB"), "wizHeader.bmp")
save(on_bg(load("logo-cyan", 128), (150, 57)).transpose(Image.FLIP_LEFT_RIGHT).convert("RGB"), "wizHeaderRTL.bmp")
save(on_bg(load("logo-cyan", 128), (164, 314)).convert("RGB"), "wizWatermark.bmp")
save(on_bg(load("logo-cyan", 256), (672, 411)).convert("L"), "stubinstaller", "bgstub.jpg")

# --- MSIX assets ---
msix = {
    "Document44x44.png": ("filesent", 44),
    "LargeTile.scale-200.png": ("logo-cyan", 620),
    "SmallTile.scale-200.png": ("logo-cyan", 142),
    "Square150x150Logo.scale-200.png": ("logo-cyan", 300),
    "Square44x44Logo.altform-lightunplated_targetsize-256.png": ("logo-cyan", 256),
    "Square44x44Logo.altform-unplated_targetsize-256.png": ("logo-cyan", 256),
    "Square44x44Logo.scale-200.png": ("logo-cyan", 88),
    "Square44x44Logo.targetsize-256.png": ("logo-cyan", 256),
    "StoreLogo.scale-200.png": ("logo-cyan", 100),
    "Wide310x150Logo.scale-200.png": ("logo-cyan", 620),
}
for name, (prefix, dim) in msix.items():
    img = load(prefix, dim)
    save(on_bg(img, (dim, dim)) if "Tile" in name or "310x150" in name else img, "msix", "Assets", name)

# --- bsys6 installer assets ---
bsys6 = os.path.join(ROOT, "..", "sentinel-bsys6", "assets")
if os.path.isdir(bsys6):
    write_ico(os.path.join(bsys6, "sentinel.ico"), "logo-cyan", S)
    # NSIS banner: wordmark on navy
    import subprocess
    wm = os.path.join(WORK, "wm-150.png")
    subprocess.run(["rsvg-convert", "-w", "150", os.path.join(ROOT, "tools/branding-src/wordmark.svg"), "-o", wm], check=True)
    banner = Image.new("RGB", (150, 57), NAVY)
    w = Image.open(wm)
    banner.paste(w, ((150-w.width)//2, (57-w.height)//2), w)
    banner.save(os.path.join(bsys6, "banner.bmp"))
    print("wrote bsys6 sentinel.ico + banner.bmp")
PYEOF
echo "ALL DONE"
