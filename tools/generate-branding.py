#!/usr/bin/env python3
"""Generate Sentinel Browser placeholder branding assets.

Draws a shield-with-eye logo programmatically and emits every raster
asset expected by browser/branding/<name> in the Firefox tree.

Replace with real artwork when available; re-run to regenerate.
"""

import math
import os
from PIL import Image, ImageDraw

BRAND_DIR = os.path.join(os.path.dirname(__file__), "..", "themes", "browser", "branding", "sentinel")

# Palette
NAVY_TOP = (13, 18, 38)      # 0D1226
NAVY_BOT = (30, 41, 82)      # 1E2952
CYAN = (56, 189, 248)        # 38BDF8
CYAN_HI = (125, 211, 252)    # 7DD3FC
VIOLET = (167, 139, 250)     # A78BFA  (private browsing accent)
VIOLET_HI = (196, 181, 253)  # C4B5FD
NAVY_PUPIL = (10, 14, 30)    # 0A0E1E


def _qbez(p0, p1, p2, n=32):
    pts = []
    for i in range(n + 1):
        t = i / n
        x = (1 - t) ** 2 * p0[0] + 2 * (1 - t) * t * p1[0] + t ** 2 * p2[0]
        y = (1 - t) ** 2 * p0[1] + 2 * (1 - t) * t * p1[1] + t ** 2 * p2[1]
        pts.append((x, y))
    return pts


def _cbez(p0, p1, p2, p3, n=48):
    pts = []
    for i in range(n + 1):
        t = i / n
        x = (1 - t) ** 3 * p0[0] + 3 * (1 - t) ** 2 * t * p1[0] + 3 * (1 - t) * t ** 2 * p2[0] + t ** 3 * p3[0]
        y = (1 - t) ** 3 * p0[1] + 3 * (1 - t) ** 2 * t * p1[1] + 3 * (1 - t) * t ** 2 * p2[1] + t ** 3 * p3[1]
        pts.append((x, y))
    return pts


def shield_poly(w, h, inset=0.0):
    """Shield outline in pixel coords, normalized geometry then scaled."""
    ix, iy = w * inset, h * inset
    w2, h2 = w - 2 * ix, h - 2 * iy
    def P(x, y):
        return (ix + x * w2, iy + y * h2)
    pts = []
    # top edge: slight dome
    pts += _qbez(P(0.18, 0.10), P(0.5, 0.05), P(0.82, 0.10))
    # right side -> tip
    pts += _cbez(P(0.82, 0.10), P(0.92, 0.34), P(0.80, 0.66), P(0.5, 0.94))[1:]
    # left side back up
    pts += _cbez(P(0.5, 0.94), P(0.20, 0.66), P(0.08, 0.34), P(0.18, 0.10))[1:]
    return pts


def vgrad(size, top, bot):
    w, h = size
    img = Image.new("RGBA", size)
    d = ImageDraw.Draw(img)
    for y in range(h):
        t = y / max(h - 1, 1)
        c = tuple(int(top[i] + (bot[i] - top[i]) * t) for i in range(3)) + (255,)
        d.line([(0, y), (w, y)], fill=c)
    return img


def draw_logo(size, accent=CYAN, accent_hi=CYAN_HI, simple=False):
    """Return RGBA Image of the Sentinel logo at `size`."""
    SS = 4
    S = size * SS
    img = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)

    # outer shield = accent border
    d.polygon(shield_poly(S, S), fill=accent + (255,))
    # inner shield = navy gradient
    inner_mask = Image.new("L", (S, S), 0)
    ImageDraw.Draw(inner_mask).polygon(shield_poly(S, S, inset=0.075), fill=255)
    img.paste(vgrad((S, S), NAVY_TOP, NAVY_BOT), (0, 0), inner_mask)

    if simple:
        # tiny sizes: just a bold accent iris dot
        r = S * 0.13
        cx, cy = S * 0.5, S * 0.44
        d.ellipse([cx - r, cy - r, cx + r, cy + r], fill=accent + (255,))
    else:
        # eye: almond outline
        ew, eh = S * 0.46, S * 0.26
        ex, ey = S * 0.5, S * 0.44
        top = _qbez((ex - ew / 2, ey), (ex, ey - eh), (ex + ew / 2, ey))
        bot = _qbez((ex + ew / 2, ey), (ex, ey + eh), (ex - ew / 2, ey))
        sw = max(int(S * 0.028), 2 * SS)
        d.line(top, fill=accent + (255,), width=sw, joint="curve")
        d.line(bot, fill=accent + (255,), width=sw, joint="curve")
        # iris + pupil
        ir = S * 0.10
        d.ellipse([ex - ir, ey - ir, ex + ir, ey + ir], fill=accent + (255,))
        pr = S * 0.048
        d.ellipse([ex - pr, ey - pr, ex + pr, ey + pr], fill=NAVY_PUPIL + (255,))
        # glint
        gr = S * 0.016
        gx, gy = ex + ir * 0.35, ey - ir * 0.35
        d.ellipse([gx - gr, gy - gr, gx + gr, gy + gr], fill=accent_hi + (255,))

    return img.resize((size, size), Image.LANCZOS)


def on_bg(logo, bg, box):
    """Logo centered on a brand background at 60% of min dimension."""
    img = Image.new("RGBA", box, bg + (255,))
    s = int(min(box) * 0.60)
    img.alpha_composite(logo.resize((s, s), Image.LANCZOS), ((box[0] - s) // 2, (box[1] - s) // 2))
    return img


def save(img, *rel):
    p = os.path.join(BRAND_DIR, *rel)
    os.makedirs(os.path.dirname(p), exist_ok=True)
    img.save(p)
    print("wrote", os.path.relpath(p, BRAND_DIR))


def main():
    logo = {s: draw_logo(s, simple=s <= 24) for s in (16, 22, 24, 32, 48, 64, 70, 128, 150, 192, 256, 270, 384)}
    logo_pb = {s: draw_logo(s, accent=VIOLET, accent_hi=VIOLET_HI, simple=s <= 24) for s in (70, 150, 270)}

    # --- default icons ---
    for s in (16, 22, 24, 32, 48, 64, 128, 256):
        save(logo[s], f"default{s}.png")

    # --- ICO files (Windows) ---
    ico_sizes = [(16, 16), (24, 24), (32, 32), (48, 48), (64, 64), (128, 128), (256, 256)]
    for name in ["firefox.ico", "firefox64.ico", "document.ico", "document_pdf.ico",
                 "newtab.ico", "newwindow.ico"]:
        p = os.path.join(BRAND_DIR, name)
        logo[256].save(p, sizes=ico_sizes)
        print("wrote", name)
    p = os.path.join(BRAND_DIR, "pbmode.ico")
    logo_pb[270].resize((256, 256), Image.LANCZOS).save(p, sizes=ico_sizes)
    print("wrote pbmode.ico")

    # --- private browsing PNGs ---
    save(logo_pb[70], "PrivateBrowsing_70.png")
    save(logo_pb[150], "PrivateBrowsing_150.png")

    # --- about dialog ---
    save(logo[192], "content", "about-logo.png")
    save(logo[384], "content", "about-logo@2x.png")
    pb192 = draw_logo(192, accent=VIOLET, accent_hi=VIOLET_HI)
    pb384 = draw_logo(384, accent=VIOLET, accent_hi=VIOLET_HI)
    save(pb192, "content", "about-logo-private.png")
    save(pb384, "content", "about-logo-private@2x.png")
    save(on_bg(logo[256], NAVY_TOP, (300, 236)).convert("RGB"), "content", "about.png")

    # --- Windows tiles ---
    save(logo[70], "VisualElements_70.png")
    save(logo[150], "VisualElements_150.png")

    # --- installer graphics ---
    save(on_bg(logo[256], NAVY_TOP, (512, 320)).convert("P", palette=Image.ADAPTIVE), "background.png")
    save(on_bg(logo[256], NAVY_TOP, (672, 411)).convert("L"), "bgstub.jpg")
    save(on_bg(logo[256], NAVY_TOP, (1344, 822)).convert("L"), "bgstub_2x.jpg")
    save(on_bg(logo[128], NAVY_TOP, (150, 57)).convert("RGB"), "wizHeader.bmp")
    save(on_bg(logo[128], NAVY_TOP, (150, 57)).transpose(Image.FLIP_LEFT_RIGHT).convert("RGB"), "wizHeaderRTL.bmp")
    save(on_bg(logo[128], NAVY_TOP, (164, 314)).convert("RGB"), "wizWatermark.bmp")
    save(on_bg(logo[256], NAVY_TOP, (672, 411)).convert("L"), "stubinstaller", "bgstub.jpg")

    # --- MSIX assets ---
    msix = {
        "Document44x44.png": (44, 44),
        "LargeTile.scale-200.png": (620, 620),
        "SmallTile.scale-200.png": (142, 142),
        "Square150x150Logo.scale-200.png": (300, 300),
        "Square44x44Logo.altform-lightunplated_targetsize-256.png": (256, 256),
        "Square44x44Logo.altform-unplated_targetsize-256.png": (256, 256),
        "Square44x44Logo.scale-200.png": (88, 88),
        "Square44x44Logo.targetsize-256.png": (256, 256),
        "StoreLogo.scale-200.png": (100, 100),
        "Wide310x150Logo.scale-200.png": (620, 300),
    }
    for name, dim in msix.items():
        save(on_bg(logo[256], NAVY_TOP, dim), "msix", "Assets", name)


if __name__ == "__main__":
    main()
