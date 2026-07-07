"""
scan_diagrams.py
Scan semua file .md dan cetak ringkasan ASCII diagram yang ditemukan.
"""
from pathlib import Path
import re

BASE = Path(__file__).parent
LANG_REAL = {"dart", "sql", "javascript", "js", "typescript", "ts",
             "python", "py", "java", "kotlin", "kt", "yaml", "yml",
             "json", "bash", "sh", "shell", "html", "css", "scss",
             "xml", "ini", "env", "toml", "markdown", "md",
             "txt", "text", "plaintext", "log", "mermaid"}
BOX_DRAWING = set("─│┌┐└┘├┤┬┴┼━┃┏┓┗┛┣┫┳┻╋╔╗╚╝╠╣╦╩╬═║►◄▼▲")
ARROWS = set("→←↑↓➜➔⇒⇐⇑⇓➤➨")


def is_ascii_diagram(text):
    box_count = sum(1 for c in text if c in BOX_DRAWING)
    arrow_count = sum(1 for c in text if c in ARROWS)
    return box_count >= 5 or arrow_count >= 4


def scan(md_path: Path):
    text = md_path.read_text(encoding="utf-8")
    lines = text.splitlines()
    last_heading = "(top of file)"

    in_code = False
    code_lang = ""
    code_lines = []
    start_idx = 0

    findings = []
    for idx, line in enumerate(lines):
        m_h = re.match(r'^(#{1,6})\s+(.+)$', line)
        if m_h and not in_code:
            last_heading = m_h.group(2).strip()

        m_f = re.match(r'^```(\w*)\s*$', line.strip())
        if m_f:
            if not in_code:
                in_code = True
                code_lang = m_f.group(1).lower()
                code_lines = []
                start_idx = idx
            else:
                in_code = False
                if code_lang not in LANG_REAL and is_ascii_diagram("\n".join(code_lines)):
                    findings.append({
                        "line": start_idx + 1,
                        "heading": last_heading,
                        "lines_count": len(code_lines),
                        "first_line": code_lines[0] if code_lines else "",
                        "preview": "\n".join(code_lines[:3])
                    })
                code_lines = []
                code_lang = ""
            continue
        if in_code:
            code_lines.append(line)

    return findings


def main():
    md_files = sorted(BASE.glob("*.md"))
    total = 0
    for md in md_files:
        if md.name.lower() == "readme.md":
            continue
        findings = scan(md)
        if not findings:
            continue
        total += len(findings)
        print(f"\n===== {md.name} ({len(findings)} diagram) =====")
        for i, f in enumerate(findings, 1):
            print(f"\n  [{i}] line {f['line']} (heading: {f['heading']!r}, {f['lines_count']} lines)")
            for pl in f["preview"].split("\n"):
                print(f"      | {pl[:80]}")
    print(f"\n--- Total: {total} diagram ditemukan ---")


if __name__ == "__main__":
    main()