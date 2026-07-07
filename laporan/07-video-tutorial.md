# 07 — Video Tutorial Pemakaian Aplikasi

Dokumen ini adalah **script** untuk membuat video tutorial/demo aplikasi. Setiap scene sudah diberi durasi, narasi, dan langkah-langkah yang harus ditampilkan.

## 7.1 Spesifikasi Video

| Aspek | Rekomendasi |
|---|---|
| Durasi total | 8-12 menit |
| Resolusi | 1080p (1920x1080) atau 720p (1280x720) |
| Frame rate | 30 fps |
| Format | MP4 (H.264) |
| Audio | Narasi jelas, volume konsisten |
| Musik latar | Opsional, instrumental lo-fi, volume rendah |

## 7.2 Tools Rekomendasi

| Untuk | Tool |
|---|---|
| Recording | OBS Studio, Camtasia, atau `adb screenrecord` |
| Edit | DaVinci Resolve (gratis), CapCut, atau OpenShot |
| Subtitle | HandBrake / YouTube auto-caption |

## 7.3 Persiapan Sebelum Rekam

- [ ] Emulator Android sudah jalan dengan app fresh-install
- [ ] Login screen sudah terbuka
- [ ] Database Supabase sudah ada data seed (5 user, 6 tiket, 5 notifikasi)
- [ ] Browser side-by-side dengan Supabase dashboard untuk demo insert real-time
- [ ] Mikrofon test, redam noise
- [ ] Mode gelap di-disable dulu (supaya jelas di video)

## 7.4 Script Scene-by-Scene

### SCENE 1 — Pembuka (0:00 - 0:30)

**Visual:** Splash screen aplikasi, logo E-Ticketing Helpdesk.

**Narasi:**
> "Halo, di video ini saya akan mendemokan aplikasi E-Ticketing Helpdesk — aplikasi mobile berbasis Flutter untuk manajemen tiket bantuan IT internal kantor. Aplikasi ini punya 3 role: User, Helpdesk, dan Admin."

**Teks overlay:** `E-TICKETING HELPDESK — UAS Aplikasi Mobile`

**Transisi:** Fade ke login screen.

---

### SCENE 2 — Login sebagai User (0:30 - 1:30)

**Visual:** Login screen kosong → ketik email → ketik password → tap LOG IN.

**Narasi:**
> "Pertama, kita login sebagai User biasa. Irsad akan membuat tiket untuk masalah laptop-nya yang sering hang."

**Langkah:**
1. Klik field Email → ketik `irsad@email.com`
2. Klik field Password → ketik `123`
3. Tap tombol LOG IN

**Hasil:** Masuk ke Dashboard Irsad, menampilkan statistik tiket dia.

**Durasi:** 60 detik.

---

### SCENE 3 — User: Buat Tiket (1:30 - 3:00)

**Visual:** Dashboard → tap tab Tiket → tap tombol + Buat → isi form → submit.

**Narasi:**
> "Irsad mau lapor laptop hang. Irsad tap tombol +, kemudian isi judul, deskripsi, pilih kategori Hardware, dan prioritas High karena menggangu kerja."

**Langkah detail:**
1. Tap tab **Tiket** di bottom navigation
2. Tap tombol **+ Buat** (di kanan bawah atau app bar)
3. Isi judul: "Laptop sering hang saat buka banyak aplikasi"
4. Isi deskripsi: "Laptop Lenovo saya selalu hang kalau buka Chrome + Excel + Word bersamaan"
5. Pilih kategori: **Hardware**
6. Pilih prioritas: **High**
7. Tap **Submit**

**Hasil:** SnackBar "Tiket berhasil dibuat", kembali ke list, tiket baru muncul di paling atas dengan badge prioritas tinggi dan status open.

**Durasi:** 90 detik.

---

### SCENE 4 — User: Lihat Notifikasi (3:00 - 3:30)

**Visual:** Tab Notifikasi, list notifikasi Irsad.

**Narasi:**
> "Setelah tiket dibuat, Irsad langsung dapat notifikasi. Semua notifikasi tentang tiket Irsad masuk di sini."

**Langkah:**
1. Tap tab **Notifikasi**
2. Tunjukkan list notifikasi, termasuk yang baru: "Tiket T-... Dibuat"

**Durasi:** 30 detik.

---

### SCENE 5 — Logout & Login sebagai Helpdesk (3:30 - 4:30)

**Visual:** Profile → Logout → Login screen → ketik `rafael@email.com` / `123`.

**Narasi:**
> "Sekarang kita ganti role. Irsad logout, lalu rafael — helpdesk — login untuk memproses tiket."

**Langkah:**
1. Tap tab **Profile** → tap tombol **Logout** → konfirmasi
2. Login screen muncul
3. Ketik `rafael@email.com` / `123`
4. Login → masuk Dashboard rafael

**Catatan:** Dashboard rafael menampilkan statistik SEMUA tiket (bukan hanya miliknya), karena dia helpdesk.

**Durasi:** 60 detik.

---

### SCENE 6 — Helpdesk: Lihat Tiket Baru (4:30 - 5:30)

**Visual:** Tab Tiket → list semua tiket → tap tiket Irsad.

**Narasi:**
> "rafael lihat antrian tiket. Yang terbaru dan prioritas High ada di paling atas. rafael buka detail tiket Irsad."

**Langkah:**
1. Tap tab **Tiket**
2. Sort by created_at DESC (default)
3. Tap kartu tiket baru yang dibuat Irsad
4. Tunjukkan halaman detail: deskripsi, info tiket, history (1 entry: "Tiket dibuat")

**Durasi:** 60 detik.

---

### SCENE 7 — Helpdesk: Ubah Status & Komentar (5:30 - 7:00)

**Visual:** Tap "Ubah Status" → dialog → pilih In Progress → isi note → submit. Lalu scroll ke bawah, ketik komentar.

**Narasi:**
> "rafael mulai mengerjakan tiket, ubah status jadi In Progress, dan tambah komentar untuk Irsad."

**Langkah:**
1. Tap **Ubah Status** di detail tiket
2. Dialog muncul → pilih **In Progress**
3. Isi note: "Sedang diagnosa, kemungkinan RAM kurang"
4. Tap **Submit**
5. Status badge tiket berubah jadi [IN PROGRESS]
6. Scroll ke bawah → kolom komentar
7. Ketik: "Pak Irsad, mohon laptop dibawa ke ruangan IT ya. Terima kasih."
8. Tap **Kirim**

**Hasil:** Komentar rafael muncul. Ticket_history bertambah 1 entry. Notifikasi baru dibuat untuk Irsad.

**Durasi:** 90 detik.

---

### SCENE 8 — (Opsional) Login Irsad Lihat Notifikasi Baru (7:00 - 7:45)

**Visual:** Logout, login Irsad, tab Notifikasi.

**Narasi:**
> "Sekarang kalau Irsad buka app lagi, dia langsung tahu ada update."

**Langkah:**
1. Logout, login Irsad
2. Tab Notifikasi → notif baru:
  - "Status Tiket T-... Berubah" (In Progress)
  - "Komentar Baru di Tiket T-..."

**Durasi:** 45 detik (boleh diskip kalau video kepanjangan).

---

### SCENE 9 — Login sebagai Admin (7:45 - 8:30)

**Visual:** Login `admin@email.com` / `123`.

**Narasi:**
> "Terakhir, kita lihat dari sisi Admin. Admin bisa kelola akun pengguna."

**Durasi:** 45 detik.

---

### SCENE 10 — Admin: User Management (8:30 - 10:30)

**Visual:** Profile → Kelola Pengguna → list user. Tambah user baru. Ubah role user. Nonaktifkan user.

**Narasi:**
> "Admin buka menu Kelola Pengguna. Di sini admin bisa lihat semua user, tambah user baru, ubah role, atau nonaktifkan akun yang sudah resign."

**Langkah:**
1. Tap tab **Profile** → tap **Kelola Pengguna** (hanya muncul untuk admin)
2. Tunjukkan list user dengan badge role
3. Tap tombol **+** → dialog "Tambah Pengguna"
4. Isi: Nama "Andi Wijaya", Email "andi@email.com", Password "123", Role **Helpdesk**
5. Tap **Submit** → Andi muncul di list
6. Tap menu **⋮** di kartu Andi → **Ubah Role** → pilih **Admin** → Submit (badge role Andi jadi Admin)
7. Tap menu **⋮** → **Nonaktifkan** → konfirmasi → Andi pindah ke section "Nonaktif"

**Durasi:** 120 detik.

---

### SCENE 11 — Penutup (10:30 - 11:00)

**Visual:** Dashboard Admin, fade ke logo aplikasi.

**Narasi:**
> "Itu tadi demo aplikasi E-Ticketing Helpdesk dari 3 sudut pandang: User, Helpdesk, dan Admin. Semua komunikasi tiket tercatat di database Supabase, ada notifikasi otomatis, dan manajemen user yang lengkap. Terima kasih sudah menonton!"

**Teks overlay:**
```
E-TICKETING HELPDESK
Built with Flutter + Supabase
UAS Aplikasi Mobile — Semester 4
```

---

## 7.5 Checklist Pasca-Rekam

- [ ] Tambah字幕 (subtitle Bahasa Indonesia) di YouTube
- [ ] Tambahkan timestamp di deskripsi:
  - 0:30 Login User
  - 1:30 Buat Tiket
  - 3:30 Login Helpdesk
  - 5:30 Ubah Status
  - 7:45 Login Admin
  - 8:30 User Management
- [ ] Thumbnail: logo E-Ticketing + teks "Demo UAS"
- [ ] Upload sebagai "Unlisted" jika tidak mau publik, atau "Public" untuk tugas
- [ ] Cantumkan link repo GitHub + database setup SQL di deskripsi

## 7.6 Tips Rekaman

1. **Jangan buru-buru** — biarkan 2-3 detik setiap transisi layar
2. **Zoom-in** saat ketik detail penting (judul tiket, komentar)
3. **Tunjukkan tanggal/waktu** real di sistem untuk bukti live
4. **Side-by-side Supabase dashboard** untuk bukti data masuk (opsional, tapi powerful)
5. **Hindari layar hitam** terlalu lama — selalu ada visual
6. **Konsisten warna** — pakai light mode untuk kejelasan
7. **Gunakan kursor atau lingkaran kuning** untuk highlight tap area

## 7.7 Script Singkat (Kalau Video Mau Lebih Pendek — 5 Menit)

| Scene | Isi | Durasi |
|---|---|---|
| 1 | Pembuka + login Irsad | 0:30 |
| 2 | Irsad buat tiket | 1:00 |
| 3 | Login rafael, ubah status | 1:30 |
| 4 | rafael tambah komentar | 0:30 |
| 5 | Login Admin, tambah user | 1:00 |
| 6 | Penutup | 0:30 |

## 7.8 Script Narasi Text-To-Speech (Alternatif Tanpa Suara)

Jika Anda lebih nyaman tanpa rekam suara, gunakan narasi teks di bawah ini dan overlay sebagai subtitle:

```
[0:00] "Halo, demo E-Ticketing Helpdesk. Aplikasi mobile Flutter dengan backend Supabase."
[0:15] "Aplikasi punya 3 role: User, Helpdesk, Admin."
[0:30] "Login sebagai User biasa, Irsad."
[1:30] "Irsad buat tiket baru untuk masalah laptop-nya."
[3:00] "Irsad dapat notifikasi otomatis."
[3:30] "Sekarang ganti ke Helpdesk, rafael."
[4:30] "rafael lihat antrian tiket Irsad."
[5:30] "rafael ubah status jadi In Progress dan tambah komentar."
[7:45] "Terakhir, Admin login."
[8:30] "Admin kelola akun: tambah, ubah role, nonaktifkan user."
[10:30] "Selesai. Terima kasih!"
```