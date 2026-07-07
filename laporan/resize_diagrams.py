"""
resize_diagrams.py
Perkecil diagram yang terlalu lebar (> 5000px) supaya pas di halaman A4
tanpa kehilangan keterbacaan. Lebar target maks 5000px.

Untuk file lain yang sudah proporsional, biarkan saja.
"""
from pathlib import Path
from PIL import Image

DIAG = Path(__file__).parent / "diagrams"
MAX_WIDTH = 5000   # px — lebih dari ini, di-shrink
KEEP_RATIO = True

resized = []
for png in sorted(DIAG.glob("*.png")):
    with Image.open(png) as im:
        w, h = im.size
        if w <= MAX_WIDTH:
            continue  # sudah cukup
        ratio = MAX_WIDTH / w
        new_w = MAX_WIDTH
        new_h = int(h * ratio)
        # Pakai LANCZOS untuk hasil terbaik
        im2 = im.resize((new_w, new_h), Image.LANCZOS)
        im2.save(png, "PNG", optimize=True)
        resized.append((png.name, w, h, new_w, new_h))

print(f"Resize {len(resized)} file:")
for name, w0, h0, w1, h1 in resized:
    print(f"  {name:25s}  {w0}x{h0}  ->  {w1}x{h1}")
