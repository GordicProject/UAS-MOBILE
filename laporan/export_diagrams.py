"""
export_diagrams.py
Scan semua file .md di folder laporan/, deteksi ASCII flow diagram
(box-drawing chars / arrows) di dalam code fence, dan render masing-masing
ke PNG di folder diagrams/.

Tujuan: menyediakan versi GAMBAR dari flow diagram di laporan — untuk
ditampilkan di sini (file lokal) tanpa perlu menyalin ke Word.

Output:
    diagrams/
        <md-filename>-<heading-hint>-<hash>.png
        manifest.json (index: file → list of {hint, png, snippet})
"""
from pathlib import Path
import re
import json
import hashlib

from render_diagrams import (
    is_ascii_diagram, ascii_to_png, DIAGRAMS_DIR,
    re_safe
)

BASE = Path(__file__).parent
MD_FILES = sorted(BASE.glob("*.md"))
LANG_REAL = {"dart", "sql", "javascript", "js", "typescript", "ts",
             "python", "py", "java", "kotlin", "kt", "yaml", "yml",
             "json", "bash", "sh", "shell", "html", "css", "scss",
             "xml", "ini", "env", "toml", "markdown", "md",
             "txt", "text", "plaintext", "log"}


def extract_diagrams(md_path: Path):
    """Kembalikan list of dict: {hint, lang, code} untuk tiap ASCII diagram."""
    text = md_path.read_text(encoding="utf-8")
    lines = text.splitlines()

    # Track heading terakhir untuk hint nama
    last_heading = ""
    diagrams = []

    in_code = False
    code_lang = ""
    code_lines = []
    fence_start_idx = 0

    for idx, line in enumerate(lines):
        # Heading detection (sederhana)
        m_h = re.match(r'^(#{1,6})\s+(.+)$', line)
        if m_h and not in_code:
            last_heading = m_h.group(2).strip()
            last_heading = re_safe(last_heading) or "diagram"

        # Code fence open/close
        m_f = re.match(r'^```(\w*)\s*$', line.strip())
        if m_f:
            if not in_code:
                in_code = True
                code_lang = m_f.group(1).lower()
                code_lines = []
                fence_start_idx = idx
            else:
                # Tutup fence → evaluasi
                in_code = False
                lang = code_lang
                code = "\n".join(code_lines)
                # Skip kalau bahasa real code (bukan diagram)
                if lang not in LANG_REAL and is_ascii_diagram(code):
                    hint = re_safe(last_heading)[:30] or "diagram"
                    diagrams.append({
                        "hint": hint,
                        "lang": lang,
                        "line_start": fence_start_idx + 1,
                        "code": code,
                    })
                code_lines = []
                code_lang = ""
            continue

        if in_code:
            code_lines.append(line)

    return diagrams


def render_one(md_name: str, hint: str, code: str) -> Path:
    h = hashlib.md5(code.encode("utf-8")).hexdigest()[:8]
    safe_md = re_safe(md_name.replace(".md", ""))
    safe_hint = re_safe(hint)[:30] or "diagram"
    name = f"{safe_md}-{safe_hint}-{h}.png"
    out = DIAGRAMS_DIR / name
    if not out.exists():
        ascii_to_png(code, out)
    return out


def main():
    DIAGRAMS_DIR.mkdir(exist_ok=True)
    manifest = {}

    for md in MD_FILES:
        if md.name.lower() == "readme.md":
            continue
        diags = extract_diagrams(md)
        if not diags:
            continue
        manifest[md.name] = []
        for d in diags:
            try:
                png = render_one(md.name, d["hint"], d["code"])
                w_px, h_px = png.stat().st_size, 0
                # Get actual px size
                from PIL import Image as _Img
                with _Img.open(png) as im:
                    w_px, h_px = im.size
                manifest[md.name].append({
                    "hint": d["hint"],
                    "line": d["line_start"],
                    "png": png.name,
                    "width_px": w_px,
                    "height_px": h_px,
                })
                print(f"  [OK] {md.name}:{d['line_start']} -> {png.name} ({w_px}x{h_px}px)")
            except Exception as e:
                print(f"  [ERR] {md.name}:{d['line_start']} -> {e}")

    # Tulis manifest
    (DIAGRAMS_DIR / "manifest.json").write_text(
        json.dumps(manifest, indent=2, ensure_ascii=False),
        encoding="utf-8"
    )
    print(f"\nManifest: {DIAGRAMS_DIR / 'manifest.json'}")
    print(f"Total file .md mengandung diagram: {len(manifest)}")
    print(f"Total diagram ter-render: {sum(len(v) for v in manifest.values())}")


if __name__ == "__main__":
    main()