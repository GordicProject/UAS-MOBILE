# 06 — Fitur per Role

## 6.1 Role & Hak Akses

```
            ┌──────────────┐
            │  👑 ADMIN    │
            │              │  (pewaris semua hak Helpdesk + User)
            └──┬───────────┘
               │ inherits
               │  ┌──────────────────┐
               ├──│  🛠 HELPDESK     │
               │  │                  │  (pewaris semua hak User)
               │  └────┬─────────────┘
               │       │ inherits
               │       │  ┌────────────────┐
               │       ├──│  👤 USER       │
               │       │  │                │
               │       │  └────────────────┘
               │       │
               │       │   FITUR EKSKLUSIF HELPDESK
               │       ├──> H1: Lihat SEMUA tiket
               │       ├──> H2: Ubah status tiket
               │       └──> H3: Assign tiket ke diri sendiri
               │
               │   FITUR EKSKLUSIF ADMIN
               ├──> A1: Kelola akun user
               ├──> A2: Tambah user baru
               ├──> A3: Ubah role user
               ├──> A4: Nonaktifkan/aktifkan user
               └──> A5: Hapus user (hard delete)


  FITUR YANG DIAKSES KETIGA ROLE (👤 | 🛠 | 👑)
  ════════════════════════════════════════════════════════════════
   C1: Buat tiket
   C2: Lihat tiket (sendiri untuk User, semua untuk Helpdesk/Admin)
   C3: Komentar di tiket
   C4: Lihat notifikasi
   C5: Profile + logout + toggle dark mode
```

## 6.2 Fitur User

### F1 — Autentikasi
- **Login** dengan email + password
- Validasi: tidak boleh kosong, password minimal 3 karakter
- Akun nonaktif ditolak (tidak bisa login walaupun password benar)
- **Register** akun baru (otomatis jadi role `user`)
- **Reset password** (saat ini simulasi, belum ganti password di DB)

### F2 — Buat Tiket
- Tap tombol "+" di tengah bottom navigation atau tombol besar di Dashboard
- Form: judul, deskripsi, kategori (dropdown), prioritas (dropdown)
- ID tiket auto-generated berbasis timestamp, misalnya `T-1720...`
- Setelah submit, otomatis:
  1. INSERT ke `tickets` (status=open)
  2. INSERT ke `ticket_history` (status=open, note="Tiket dibuat")
  3. INSERT ke `notifications` melalui `TicketProvider`
  4. Pop ke list dan refresh

### F3 — Lihat Tiket Saya
- Tab "Tiket" menampilkan tiket yang dibuat oleh user login
- Tiap kartu menampilkan: ID, judul, status badge, priority chip, tanggal
- Tap kartu → buka detail
- Tap "+" → buat baru
- Filter status (chip horizontal): Semua / Open / In Progress / Resolved / Closed

### F4 — Komentar di Tiket
- Pada halaman detail tiket, scroll ke bawah → kolom komentar
- Input + tombol "Kirim"
- Setiap komentar menambah updated_at tiket dan insert notifikasi

### F5 — Notifikasi
- Tab "Notifikasi" menampilkan semua notif terbaru
- Tap notif yang berticket → buka detail tiket
- Tap ikon centang di appbar → tandai semua sudah dibaca
- Pull-to-refresh untuk update

### F6 — Profile
- Lihat nama, email, role, avatar
- Ganti dark mode / light mode
- Tombol logout

## 6.3 Fitur Helpdesk (semua fitur User + )

### F7 — Lihat Semua Tiket
- Tab Tiket menampilkan SEMUA tiket (bukan hanya miliknya)
- Toggle "Semua Tiket" vs "Tiket Saya" (untuk konteks)
- Sort by created_at DESC (terbaru di atas)

### F8 — Ubah Status Tiket
- Di halaman detail, tap tombol "Ubah Status"
- Muncul dialog dengan 4 opsi: Open / In Progress / Resolved / Closed
- Pilih → opsional isi note → submit
- Sistem otomatis:
  1. UPDATE `tickets.status` + `updated_at`
  2. INSERT ke `ticket_history` dengan note
  3. INSERT notifikasi

### F9 — Assign Tiket
- Helpdesk bisa assign tiket ke diri sendiri (saat ini tidak ada dropdown assignee UI; assigned_to di-set lewat `updateTicketStatus` parameter)
- Alternatif: admin assign manual di Supabase dashboard (untuk UAS)

## 6.4 Fitur Admin (semua fitur Helpdesk + )

### F10 — User Management
- Akses dari Profile → tombol "Kelola Pengguna" (hanya tampil untuk admin)
- Lihat list user dipisah AKTIF / NONAKTIF
- Search bar untuk cari user
- Tombol "+" → dialog "Tambah Pengguna":
  - Input nama, email, password, role
  - Submit → INSERT ke users + INSERT notifikasi sistem

### F11 — Ubah Role User
- Di kartu user, tap menu "⋮" → "Ubah Role"
- Dialog dengan radio button: user / helpdesk / admin
- Submit → UPDATE users.role + INSERT notifikasi

### F12 — Nonaktifkan / Aktifkan User
- Tap menu "⋮" → "Nonaktifkan" / "Aktifkan"
- Soft-delete: UPDATE users.is_active = false (atau true)
- User nonaktif tidak bisa login (dicek di `SupabaseService.login`)
- INSERT notifikasi sistem

### F13 — Hapus User
- Tap menu "⋮" → "Hapus"
- Konfirmasi dialog → hard delete
- INSERT notifikasi sistem

## 6.5 Matriks Aksi per Layar

| Layar | User | Helpdesk | Admin |
|---|---|---|---|
| Login | ✅ | ✅ | ✅ |
| Register | ✅ | - | - |
| Dashboard | ✅ (statistik sendiri) | ✅ (statistik semua) | ✅ (statistik semua) |
| Tiket List (semua) | ❌ (hanya miliknya) | ✅ | ✅ |
| Tiket List (filter "Tiket Saya") | ✅ | ✅ | ✅ |
| Buat Tiket | ✅ | ✅ | ✅ |
| Tiket Detail - Lihat | ✅ (jika miliknya) | ✅ (semua) | ✅ |
| Tiket Detail - Komentar | ✅ | ✅ | ✅ |
| Tiket Detail - Ubah Status | ❌ | ✅ | ✅ |
| Notifikasi | ✅ | ✅ | ✅ |
| Profile | ✅ | ✅ | ✅ |
| User Management | ❌ | ❌ | ✅ |

## 6.6 Skenario Penggunaan Lengkap

### Skenario 1 — Irsad Buat Tiket Baru
1. Irsad login (`irsad@email.com` / `123`)
2. Tap tab **Tiket** → tap tombol **+ Buat**
3. Isi judul "Printer tidak bisa print warna", deskripsi "Hasil print hanya hitam putih", kategori **Hardware**, prioritas **Medium**
4. Tap **Submit** → muncul SnackBar "Tiket berhasil dibuat"
5. Tap tab **Notifikasi** → muncul notif "Tiket T-... Dibuat"

### Skenario 2 — rafael Proses Tiket Irsad
1. rafael login (`rafael@email.com` / `123`)
2. Tap tab **Tiket** → lihat tiket Irsad (T-...)
3. Tap kartu → buka detail
4. Tap **Ubah Status** → pilih **In Progress** → isi note "Sedang cek printer" → Submit
5. Scroll ke komentar → tulis "Saya akan ke lokasi, mohon tunggu 30 menit" → Kirim
6. Irsad (di HP lain) buka app → tab Notifikasi → dapat 2 notif:
  - "Status Tiket T-... Berubah" (In Progress)
  - "Komentar Baru di Tiket T-..."

### Skenario 3 — rafael Selesaikan
1. Kembali ke Tiket Detail
2. **Ubah Status** → **Resolved** → note "Driver printer di-update, silakan coba"
3. Irsad dapat notif "Status Tiket T-... Berubah" (Resolved)

### Skenario 4 — Admin Tambah Helpdesk Baru
1. Admin login (`admin@email.com` / `123`)
2. Tap tab **Profile** → tap **Kelola Pengguna**
3. Tap tombol **+** di appbar
4. Isi: Nama "Andi Wijaya", Email "andi@email.com", Password "123", Role "helpdesk"
5. Submit → Andi muncul di list, semua notifikasi sistem dibuat
6. Andi bisa langsung login

### Skenario 5 — Admin Nonaktifkan User Resign
1. Di **Kelola Pengguna**, cari user "Ex-Helpdesk"
2. Tap menu **⋮** → **Nonaktifkan**
3. Konfirmasi → user pindah ke section "Nonaktif"
4. Coba login dengan akun Ex-Helpdesk → ditolak ("Akun dinonaktifkan")

## 6.7 Statistik yang Ditampilkan di Dashboard

Dashboard menampilkan ringkasan tergantung role:

**User:**
- Tiket saya: Open, In Progress, Done
- 5 tiket terbaru saya

**Helpdesk / Admin:**
- Total semua tiket: Open, In Progress, Resolved, Closed
- Tiket yang di-assign ke saya
- 5 tiket terbaru global