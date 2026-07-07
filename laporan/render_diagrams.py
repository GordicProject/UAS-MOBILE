"""
render_diagrams.py
Render ASCII flow diagram (box-drawing) ke PNG menggunakan Pillow.

Cara kerja:
  1. Tentukan lebar text ASCII (line terpanjang).
  2. Render tiap char ke image monospace (Consolas). Box-drawing chars
     (─│┌┐└┘├┤┬┴┼╔╗╚╝╠╣╦╩╬═║►◄▼▲→←↑↓•█░) di-render apa adanya.
  3. Tambah padding + grid subtle.
  4. Save ke PNG dengan anti-alias monospace font.

Output: float width/height in pixel, plus width_in untuk DOCX scaling.
"""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont
import hashlib

# ── Path ────────────────────────────────────────────────────────────────
DIAGRAMS_DIR = Path(__file__).parent / "diagrams"
DIAGRAMS_DIR.mkdir(exist_ok=True)

# ── Font (monospace, support box-drawing + Unicode) ────────────────────
FONT_PATH = r"C:\Windows\Fonts\lucon.ttf"   # Lucida Console — unicode-rich
BACKUP_FONTS = [r"C:\Windows\Fonts\consola.ttf", r"C:\Windows\Fonts\cour.ttf"]

def _load_font(size: int) -> ImageFont.FreeTypeFont:
    try:
        return ImageFont.truetype(FONT_PATH, size)
    except Exception:
        for p in BACKUP_FONTS:
            try:
                return ImageFont.truetype(p, size)
            except Exception:
                continue
        return ImageFont.load_default()

# ── Character widths (rough, monospace) ─────────────────────────────────
FONT_SIZE  = 13
FONT_RENDER = 14  # slightly larger for crispness
LINE_HEIGHT = 17

def _char_width(font):
    # Sample width pakai 'M' (typical monospace advance)
    bbox = font.getbbox("M")
    return bbox[2] - bbox[0]

CHAR_W = _char_width(_load_font(FONT_RENDER))

# ── Detect ASCII diagram vs code ────────────────────────────────────────
# Heuristic: minimal ada 3 box-drawing chars ATAU banyak arrows
BOX_DRAWING = set("─│┌┐└┘├┤┬┴┼━┃┏┓┗┛┣┫┳┻╋╔╗╚╝╠╣╦╩╬═║►◄▼▲")
ARROWS = set("→←↑↓➜➔⇒⇐⇑⇓➤➨")

def is_ascii_diagram(text: str) -> bool:
    """Return True kalau text kelihatan seperti ASCII diagram."""
    box_count = sum(1 for c in text if c in BOX_DRAWING)
    arrow_count = sum(1 for c in text if c in ARROWS)
    # Minimal salah satu kuat
    return box_count >= 5 or arrow_count >= 4

def ascii_to_png(text: str, out_path: Path, bg=(255, 255, 255), fg=(20, 20, 20)) -> tuple[int, int]:
    """Render ASCII text ke PNG. Return (width_px, height_px)."""
    lines = text.splitlines()
    # Drop trailing empty lines
    while lines and not lines[-1].strip():
        lines.pop()

    font = _load_font(FONT_RENDER)
    cw = CHAR_W
    lh = LINE_HEIGHT

    # Find widest line
    max_chars = max(len(l) for l in lines) if lines else 0
    # Padding
    pad_x = 18
    pad_y = 14

    width_px = max_chars * cw + pad_x * 2
    height_px = len(lines) * lh + pad_y * 2

    # Bikin image dengan background
    img = Image.new("RGB", (width_px, height_px), bg)
    draw = ImageDraw.Draw(img)

    # Render tiap baris
    y = pad_y
    for line in lines:
        draw.text((pad_x, y), line, font=font, fill=fg)
        y += lh

    img.save(out_path, "PNG", optimize=True)
    return width_px, height_px


def render_diagram_block(code_text: str, hint: str = "") -> Path:
    """Render 1 code-block ASCII jadi PNG.
    Nama file hasil = hash(content + hint)[:10] + .png
    hint = nama section (mis. 'flow-login') supaya nama human-readable."""
    h = hashlib.md5((hint + code_text).encode("utf-8")).hexdigest()[:10]
    safe_hint = re_safe(hint)[:30]
    out_name = f"{safe_hint}-{h}.png" if safe_hint else f"diagram-{h}.png"
    out_path = DIAGRAMS_DIR / out_name
    if not out_path.exists():
        ascii_to_png(code_text, out_path)
    return out_path


def re_safe(s: str) -> str:
    """Buat nama file aman dari string."""
    import re as _re
    s = _re.sub(r"[^a-zA-Z0-9-_]+", "-", s.lower()).strip("-")
    return s or ""


def estimate_docx_width(width_px: int) -> float:
    """Estimasi lebar di Word (inch). Asumsi image 150 dpi.
    Default lebar page (A4 minus margin) ≈ 6.0 inch."""
    inches = width_px / 150.0
    return min(inches, 6.0)  # clamp ke max 6.0 inch


if __name__ == "__main__":
    # Test
    sample = """
┌──────────┐
│  HELLO   │
└──────────┘
    """
    p = DIAGRAMS_DIR / "test.png"
    w, h = ascii_to_png(sample, p)
    print(f"OK: {p}  ({w}x{h}px)")
