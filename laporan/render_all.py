"""
render_all.py — Re-render SEMUA diagram dari file .mmd dengan tema neo-brutalism
dan ukuran besar yang cocok untuk dicetak di Word (.docx).

Output:
- diagrams/02-1-hl.png
- diagrams/02-2-fix.png ... 02-13-fix.png
- diagrams/flow-login.png
- diagrams/03-1-fix.png  (ERD)
"""
import subprocess
import sys
from pathlib import Path

BASE = Path(__file__).parent
CFG  = BASE / "mermaid-config.json"
DIAG = BASE / "diagrams"
PUPPETEER_CFG = BASE / "puppeteer-config.json"

# Skema: nama mermaid source -> nama output PNG (harus cocok dengan yang dirujuk di .md)
RENDER_MAP = {
    "d1.mmd":           "02-1-hl.png",        # arsitektur high-level
    "d2.mmd":           "02-2-fix.png",       # alur data
    "d3.mmd":           "02-3-fix.png",       # MVVM sequence
    "d4.mmd":           "02-4-fix.png",       # flow buat tiket
    "d5.mmd":           "02-5-fix.png",       # flow ubah status
    "d6.mmd":           "02-6-fix.png",       # flow notifikasi
    "d7.mmd":           "02-7-fix.png",       # struktur folder
    "d8.mmd":           "02-8-fix.png",       # routing GoRouter
    "d9.mmd":           "02-9-fix.png",       # lifecycle state
    "d10.mmd":          "02-10-fix.png",      # lifecycle detail
    "d11.mmd":          "02-11-fix.png",      # use case diagram
    "d12.mmd":          "02-12-fix.png",      # activity buat tiket
    "d13.mmd":          "02-13-fix.png",      # component diagram
    "d-login.mmd":      "flow-login.png",     # login flow
    "d-erd.mmd":        "03-1-fix.png",       # ERD database
}

PUPPETEER_CFG_BODY = '{"args": ["--no-sandbox", "--disable-setuid-sandbox"]}'


def ensure_puppeteer_config():
    if not PUPPETEER_CFG.exists():
        PUPPETEER_CFG.write_text(PUPPETEER_CFG_BODY)


def render_one(src: Path, dst_name: str):
    dst = DIAG / dst_name
    if not src.exists():
        print(f"  [SKIP] {src.name} not found")
        return False
    mmdc_bin = BASE / "node_modules" / ".bin" / "mmdc.cmd"
    cmd = (
        f'"{mmdc_bin}" '
        f'-i "{src}" '
        f'-o "{dst}" '
        f'-t default '
        f'-b "#FFF6E0" '
        f'-w 2000 '
        f'-H 2400 '
        f'-s 2 '
        f'-c "{CFG}" '
        f'--puppeteerConfigFile "{PUPPETEER_CFG}"'
    )
    print(f"  [RENDER] {src.name} -> {dst_name}")
    try:
        result = subprocess.run(
            cmd,
            cwd=str(BASE),
            shell=True,                # biar .cmd bisa di-resolve
            capture_output=True,
            text=True,
            timeout=180,
        )
        if result.returncode == 0 and dst.exists():
            size_kb = dst.stat().st_size / 1024
            print(f"             OK ({size_kb:.0f} KB)")
            return True
        else:
            err = (result.stderr or result.stdout or "")[:300]
            print(f"             ERR: {err}")
            return False
    except subprocess.TimeoutExpired:
        print(f"             TIMEOUT")
        return False
    except Exception as e:
        print(f"             EXCEPTION: {e}")
        return False


def main():
    DIAG.mkdir(exist_ok=True)
    ensure_puppeteer_config()

    print(f"Render {len(RENDER_MAP)} diagram dengan tema neo-brutalism\n")
    ok = 0
    fail = 0
    for src_name, dst_name in RENDER_MAP.items():
        src = BASE / src_name
        if render_one(src, dst_name):
            ok += 1
        else:
            fail += 1

    print(f"\n=== Selesai: {ok} berhasil, {fail} gagal ===")
    return 0 if fail == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
