# Laporan UAS — Aplikasi Mobile eTicketing Helpdesk

> **Mata Kuliah:** Aplikasi Mobile
> **Jenis:** UAS (Ujian Akhir Semester) Teori
> **Aplikasi:** eTicketing Helpdesk — Sistem tiket bantuan internal kantor

---

## 📑 Daftar Isi Laporan

| # | Dokumen | Isi |
|---|---------|-----|
| 1 | [01-pendahuluan.md](01-pendahuluan.md) | Latar belakang, tujuan, scope, user persona |
| 2 | [02-arsitektur.md](02-arsitektur.md) | Flow diagram, tech stack, MVVM pattern, sequence diagram |
| 3 | [03-database.md](03-database.md) | Skema tabel, ERD, relasi, seed data |
| 4 | [04-api.md](04-api.md) | REST API Supabase yang dipakai, operasi per fitur |
| 5 | [05-uiux.md](05-uiux.md) | Daftar layar, flow navigasi, design system (brutalism) |
| 6 | [06-fitur.md](06-fitur.md) | Fitur per role (user / helpdesk / admin) |
| 7 | [07-video-tutorial.md](07-video-tutorial.md) | Script screencast, scene-by-scene, checklist rekaman |
| 8 | [08-panduan-deploy.md](08-panduan-deploy.md) | Cara install Flutter, setup Supabase, run aplikasi |
| 9 | [09-dokumentasi-kode.md](09-dokumentasi-kode.md) | Struktur folder, modul penting, snippet penting |

---

## 🎯 Ringkasan Singkat

**eTicketing Helpdesk** adalah aplikasi mobile (Flutter) yang dipakai karyawan sebuah kantor untuk melaporkan gangguan IT (hardware/software/network). Laporan masuk sebagai tiket, lalu diproses helpdesk, dan diawasi admin.

- **Platform:** Flutter 3.x (Android & iOS)
- **Backend:** Supabase (PostgreSQL + Auth + Storage)
- **Arsitektur:** MVVM (Model–View–ViewModel/Provider)
- **State management:** Provider (ChangeNotifier)
- **Routing:** GoRouter dengan shell route (bottom navigation)
- **Design language:** Neo-brutalism (warna bold, border hitam tebal, hard shadow)

### 👥 3 Role Pengguna
| Role | Hak Akses |
|------|-----------|
| **User** | Buat tiket, lihat tiket sendiri, komentar di tiket sendiri |
| **Helpdesk** | Semua hak user + lihat semua tiket, ubah status, komentar |
| **Admin** | Semua hak helpdesk + kelola pengguna (CRUD, aktif/nonaktif, ubah role) |

### 🗂️ Sumber Database
- Project Supabase: `eblilamcydtnafqhzcxa`
- 6 tabel: `users`, `tickets`, `comments`, `ticket_history`, `notifications`, `ticket_attachments`
- 5 akun demo (password semua: `123`) — Irsad, Azzam (user); rafael, Dewi (helpdesk); Admin (admin)
- 6 tiket demo dengan history dan komentar

---

## 🔧 Cara Membaca Laporan

1. **Untuk presentasi/demo:** mulai dari [01-pendahuluan.md](01-pendahuluan.md) lalu lompat ke [07-video-tutorial.md](07-video-tutorial.md) untuk nonton demo.
2. **Untuk review kode:** langsung ke [09-dokumentasi-kode.md](09-dokumentasi-kode.md) dan [02-arsitektur.md](02-arsitektur.md).
3. **Untuk pasang ulang:** ikut [08-panduan-deploy.md](08-panduan-deploy.md).

---

## 🔨 Cara Generate Ulang Dokumen Output

```bash
cd "/d C:\Users\raide\Documents\FILE\Semester 4\Aplikasi mobile\Praktikum Aplikasi mobile\uas mobile\eTicketing\laporan"

# 1. Build DOCX dari Markdown (.md → .docx)
python build_docx.py

# 2. Convert DOCX ke PDF (Microsoft Word COM automation)
python docx_to_pdf.py
```

Output akhir:
- `Laporan_UAS_eTicketing_Helpdesk.docx` (~90 KB)
- `Laporan_UAS_eTicketing_Helpdesk.pdf` (~4-5 MB)

**Prasyarat:**
- Python dengan `python-docx` (sudah ada di Laragon).
- Microsoft Word terinstall + `pip install pywin32` (untuk langkah #2).
- File `.docx` **tidak boleh terbuka** di Word saat konversi PDF (tutup dulu).

---

*Disusun sebagai tugas UAS Teori — Aplikasi Mobile, Semester 4.*