# Diagram Referensi — Seluruh Laporan

Seluruh diagram di proyek ini tersedia sebagai file sumber (`.mmd` atau ASCII art) dan gambar `.png` di subfolder `diagrams/`.

## Daftar Diagram per BAB

### BAB 2 — Arsitektur Sistem (02-arsitektur.md)

| No | Nama Diagram | Format Mermaid | Gambar |
|----|-------------|---------------|--------|
| 1  | Arsitektur High-Level | d1.mmd | [diagrams/02-1-hl.png](diagrams/02-1-hl.png) |
| 2  | Alur Data Singkat | d2.mmd | [diagrams/02-2-fix.png](diagrams/02-2-fix.png) |
| 3  | MVVM Sequence | d3.mmd | [diagrams/02-3-fix.png](diagrams/02-3-fix.png) |
| 4  | Flow Buat Tiket | d4.mmd | [diagrams/02-4-fix.png](diagrams/02-4-fix.png) |
| 5  | Flow Ubah Status | d5.mmd | [diagrams/02-5-fix.png](diagrams/02-5-fix.png) |
| 6  | Flow Notifikasi | d6.mmd | [diagrams/02-6-fix.png](diagrams/02-6-fix.png) |
| 7  | Struktur Folder Proyek | d7.mmd | [diagrams/02-7-fix.png](diagrams/02-7-fix.png) |
| 8  | Routing GoRouter | d8.mmd | [diagrams/02-8-fix.png](diagrams/02-8-fix.png) |
| 9  | Lifecycle State | d9.mmd | [diagrams/02-9-fix.png](diagrams/02-9-fix.png) |
| 10 | Lifecycle Detail | d10.mmd | [diagrams/02-10-fix.png](diagrams/02-10-fix.png) |
| 11 | Use Case Diagram | d11.mmd | [diagrams/02-11-fix.png](diagrams/02-11-fix.png) |
| 12 | Activity Buat-Tiket-Selesai | d12.mmd | [diagrams/02-12-fix.png](diagrams/02-12-fix.png) |
| 13 | Component Diagram | d13.mmd | [diagrams/02-13-fix.png](diagrams/02-13-fix.png) |
| 14 | Login Flow | d-login.mmd | [diagrams/flow-login.png](diagrams/flow-login.png) |

### BAB 3 — Database (03-database.md)

| No | Nama Diagram | Sumber | Gambar |
|----|-------------|--------|--------|
| 1  | ERD | d-erd.mmd | [diagrams/03-1-fix.png](diagrams/03-1-fix.png) |

## Render Ulang Semua Diagram

```bash
# BAB 2 — Arsitektur (setiap nomor)
npx mmdc -i d<N>.mmd -o diagrams/02-<N>-fix.png -b transparent   # N=1..13
npx mmdc -i d-login.mmd -o diagrams/flow-login.png -b transparent

# BAB 3 — Database
npx mmdc -i d-erd.mmd -o diagrams/03-1-fix.png -b transparent
```
