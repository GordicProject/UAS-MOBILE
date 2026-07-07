# 01 — Pendahuluan

## 1.1 Latar Belakang

Di lingkungan kantor modern, hampir semua aktivitas bergantung pada perangkat IT: laptop, printer, jaringan internet, software kantor, dan VPN untuk kerja remote. Ketika ada masalah — laptop hang, printer error, WiFi putus, tidak bisa login VPN — karyawan bingung harus lapor ke siapa, dan tim IT kesulitan melacak laporan yang masuk.

**Tanpa sistem:** laporan masuk via WhatsApp random, email tercecer, atau teriakan di koridor. Tim IT tidak punya catatan status, tidak tahu tiket mana yang sudah selesai, dan karyawan tidak bisa cek progress.

**Solusi:** aplikasi mobile **eTicketing Helpdesk** yang:
- Karyawan bisa **buat tiket dari HP** kapan saja, lengkap dengan kategori dan prioritas.
- Helpdesk bisa **lihat antrian tiket, ubah status, dan kasih komentar**.
- Admin bisa **kelola akun pengguna** dan mengawasi keseluruhan.
- Semua notifikasi perubahan masuk otomatis.

## 1.2 Tujuan Aplikasi

1. **Sentralisasi laporan IT** — semua tiket masuk ke satu database terstruktur.
2. **Transparansi progress** — karyawan bisa lihat status tiketnya real-time.
3. **Efisiensi helpdesk** — tidak perlu cari laporan, tinggal buka list.
4. **Audit trail** — ada history perubahan status + komentar.
5. **Manajemen pengguna** — admin bisa tambah/nonaktifkan/ubah role akun.

## 1.3 Scope (Batasan)

**Yang aplikasi ini kerjakan:**
- Autentikasi email + password (plain text, untuk demo).
- CRUD tiket oleh user.
- Update status tiket oleh helpdesk.
- Komentar di tiket (semua role).
- Notifikasi in-app.
- Upload attachment (gambar/dokumen) ke Supabase Storage.
- Manajemen user oleh admin.
- Dark mode / light mode.
- Bottom navigation 3 tab (Beranda, Tiket, Notifikasi).

**Yang BELUM ada (future work):**
- Push notification (FCM) — saat ini cuma notif in-app.
- Email notifikasi.
- Multi-language (saat ini hanya Bahasa Indonesia).
- SLA tracking / timer.
- Dashboard analytics dengan chart.
- Approval workflow.

## 1.4 User Persona

### Persona 1 — Irsad (User)
- **Profil:** staff admin kantor, 27 tahun.
- **Kebutuhan:** laptop-nya sering hang, tidak tahu harus lapor ke mana.
- **Skenario:** buka app → "Tiket" → "+ Buat" → isi judul "Laptop hang" → pilih kategori Hardware → prioritas High → submit. Buka notifikasi untuk lihat update dari helpdesk.

### Persona 2 — Azzam (User)
- **Profil:** staf marketing, 26 tahun, sering kerja remote via VPN.
- **Kebutuhan:** akses cepat ke helpdesk saat WiFi kantor atau VPN bermasalah.
- **Skenario:** buka app → "Tiket" → "+ Buat" → kategori Network → prioritas High → submit. Pantau status tiket dari tab Notifikasi.

### Persona 3 — rafael (Helpdesk)
- **Profil:** teknisi IT, 32 tahun, handle 50+ karyawan.
- **Kebutuhan:** antrian tiket yang jelas, tahu mana yang prioritas tinggi.
- **Skenario:** buka app → "Tiket" → lihat semua tiket → sort by prioritas → kerjakan → ubah status jadi "In Progress" → tambah komentar → jika selesai, ubah jadi "Resolved".

### Persona 4 — Admin
- **Profil:** kepala IT, 38 tahun, supervise 2 helpdesk.
- **Kebutuhan:** kelola akun helpdesk, nonaktifkan akun yang resign, pastikan semua tiket tertangani.
- **Skenario:** buka app → tab Notifikasi → lihat ringkasan aktivitas → buka "Kelola Pengguna" dari profile → tambah helpdesk baru, ubah role user, nonaktifkan akun lama.

## 1.5 Metodologi Pengembangan

- **Model:** Solo development (1 orang).
- **Durasi:** ~6 minggu (modul, mid, UAS).
- **Tools:** VS Code, Flutter SDK, Android Studio (emulator), Supabase Cloud, Git.
- **Testing:** manual end-to-end (login → buat tiket → ubah status → notifikasi masuk).
- **Version control:** Git + GitHub.

## 1.6 Teknologi yang Dipilih (dan Alasan)

| Pilihan | Alternatif | Alasan |
|---|---|---|
| **Flutter** | React Native, native | Single codebase, hot reload cepat, paket UI lengkap |
| **Supabase** | Firebase, custom backend | Postgres SQL (familiar), free tier cukup, RLS built-in |
| **Provider** | Riverpod, Bloc, GetX | Paling sederhana, bawaan flutter, dokumentasi lengkap |
| **GoRouter** | Navigator 1.0 | URL-style routing, cocok untuk deep link |
| **Neo-brutalism** | Material default | Out-of-the-box, distinctive, mudah dikenali |

## 1.7 Struktur Laporan

Dokumen ini dibagi per-bab di file terpisah (lihat README.md). Masing-masing bab dapat berdiri sendiri tapi dirujuk silang.
