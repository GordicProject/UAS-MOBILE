# 05 — UI / UX Aplikasi

## 5.1 Design Language: Neo-Brutalism

eTicketing menggunakan gaya **Neo-Brutalism** — gaya desain yang terinspirasi dari situs web indie tahun 90-an/2000-an awal:

### Prinsip Utama
| Prinsip | Implementasi |
|---|---|
| **Warna bold** | Kuning primer `#FFD700`, pink neon `#FF3D7F`, orange `#FF7A00`, lime `#73F74D` |
| **Border hitam tebal** | 3-4px black border di setiap container |
| **Hard shadow** | `BoxShadow` offset (4,4) blur 0 (tidak ada blur, hanya offset) |
| **Tipografi block letter** | `Space Grotesk` weight 800-900, letter-spacing lebar untuk label |
| **Kontras tinggi** | Hitam pekat di atas kuning/krem |
| **Tanpa gradien** | Warna flat, tegas |
| **Tanpa border-radius besar** | Hanya 2-4px radius (sedikit dihaluskan) |

### Palette Warna

```
LIGHT MODE
  Background:    #FFF6E0 (krem)
  Surface:       #FFFFFF
  Text:          #000000
  Border:        #000000
  Primary:       #FFD700 (kuning)

DARK MODE
  Background:    #0D0D0D
  Surface:       #1E1E1E
  Text:          #FFFBF0 (krem terang)
  Border:        #FFFBF0
  Primary:       #FFD700 (kuning tetap)
```

### Status & Priority Colors

| Status | Color | Hex |
|---|---|---|
| `open` | Pink Neon | `#FF3D7F` |
| `inProgress` | Orange | `#FF7A00` |
| `resolved` | Lime Green | `#73F74D` |
| `closed` | Abu-abu | `#C0C0C0` |

| Priority | Color |
|---|---|
| `high` | Red |
| `medium` | Orange |
| `low` | Lime |

## 5.2 Daftar Layar (14 Total)

| # | Layar | File | Dilihat Oleh |
|---|---|---|---|
| 1 | Splash | `splash_screen.dart` | Semua |
| 2 | Login | `login_screen.dart` | Semua (belum login) |
| 3 | Register | `register_screen.dart` | User baru |
| 4 | Reset Password | `reset_password_screen.dart` | Lupa password |
| 5 | Main Shell (BottomNav) | `main_shell.dart` | Sudah login |
| 6 | Dashboard | `dashboard_screen.dart` | Semua (shell tab 1) |
| 7 | Tiket List | `ticket_list_screen.dart` | Semua (shell tab 2) |
| 8 | Tiket Detail | `ticket_detail_screen.dart` | Semua |
| 9 | Buat Tiket | `create_ticket_screen.dart` | User, Helpdesk |
| 10 | Notifikasi | `notification_screen.dart` | Semua (shell tab 3) |
| 11 | Profile | `profile_screen.dart` | Semua (shell tab 4) |
| 12 | User Management | `admin/user_management_screen.dart` | Admin only |
| 13 | Add User (dialog) | (di dalam #12) | Admin only |
| 14 | Edit User (dialog) | (di dalam #12) | Admin only |

## 5.3 Wireframe (ASCII)

### 5.3.1 Login Screen
```
┌──────────────────────────────────┐
│ [ICON HELPDESK]                  │
│                                  │
│        E-TICKETING               │
│      HELPDESK                    │
│                                  │
│  ┌────────────────────────────┐  │
│  │ Email                       │  │
│  └────────────────────────────┘  │
│  ┌────────────────────────────┐  │
│  │ Password              [eye] │  │
│  └────────────────────────────┘  │
│                                  │
│  ┌────────────────────────────┐  │
│  │         LOG IN              │  │
│  └────────────────────────────┘  │
│                                  │
│  Belum punya akun? Daftar        │
│  Lupa password? Reset            │
└──────────────────────────────────┘
```

### 5.3.2 Dashboard (Tergantung Role)
```
┌──────────────────────────────────┐
│  ◀  HELLO, BUDI                  │
│                                  │
│  ┌────────────────────────────┐  │
│  │  [ICON]  BUAT TIKET BARU   │  │
│  │  Lapor masalah IT          │  │
│  └────────────────────────────┘  │
│                                  │
│  STATISTIK TIKET SAYA            │
│  ┌────────┐ ┌────────┐ ┌──────┐  │
│  │   3    │ │   1    │ │  2   │  │
│  │ OPEN   │ │IN PROG │ │DONE  │  │
│  └────────┘ └────────┘ └──────┘  │
│                                  │
│  TIKET TERBARU                   │
│  ┌────────────────────────────┐  │
│  │ T-1720... [HIGH] [IN PROG] │  │
│  │ Laptop sering hang         │  │
│  │ 2 Jul • Hardware           │  │
│  └────────────────────────────┘  │
│  ┌────────────────────────────┐  │
│  │ T-1721... [HIGH] [RESOLVED]│  │
│  │ WiFi drop setiap jam 10    │  │
│  └────────────────────────────┘  │
└──────────────────────────────────┘
│  [Beranda] [Tiket] [Notif] [Profile] │
```

### 5.3.3 Ticket List (Semua Tiket untuk Helpdesk/Admin)
```
┌──────────────────────────────────┐
│  TIKET     [Filter ▾] [Cari 🔍] │
│                                  │
│  STATUS                           │
│  [Semua][Open][InProgress][Done]  │
│                                  │
│  ┌────────────────────────────┐  │
│  │ T-1720... [MED] [OPEN]     │  │
│  │ Tidak bisa print           │  │
│  │ 3 Jul • oleh Siti          │  │
│  └────────────────────────────┘  │
│  ┌────────────────────────────┐  │
│  │ T-1721... [MED] [OPEN]     │  │
│  │ Monitor LCD rusak          │  │
│  └────────────────────────────┘  │
│                                  │
│  ┌─────────────┐                  │
│  │    + BUAT   │                  │
│  └─────────────┘                  │
└──────────────────────────────────┘
```

### 5.3.4 Ticket Detail
```
┌──────────────────────────────────┐
│  ◀   TIKET T-1720...     [⋮]   │
│                                  │
│  [HIGH]  [IN PROGRESS]           │
│  Laptop sering hang saat buka    │
│  banyak aplikasi                 │
│                                  │
│  ┌── Deskripsi ────────────────┐ │
│  │ Laptop Lenovo saya selalu    │ │
│  │ hang kalau buka Chrome +     │ │
│  │ Excel + Word bersamaan...    │ │
│  └──────────────────────────────┘ │
│                                  │
│  ┌── Info ─────────────────────┐ │
│  │ Kategori: Hardware          │ │
│  │ Prioritas: High             │ │
│  │ Dibuat:    1 Jul, 08:00     │ │
│  │ Assigned:  rafael Anandi    │ │
│  └──────────────────────────────┘ │
│                                  │
│  [UBAH STATUS]  [+] ATTACHMENT   │
│                                  │
│  ─── HISTORY ────────────────── │
│  • 1 Jul: Open (Tiket dibuat)    │
│  • 2 Jul: InProgress (Diagnosa)  │
│                                  │
│  ─── KOMENTAR ───────────────── │
│  [rafael Anandi]                 │
│  Sudah dicek, perlu upgrade RAM  │
│                                  │
│  ┌──────────────────────────┐   │
│  │ Ketik komentar...         │   │
│  └──────────────────────────┘   │
│  [KIRIM]                         │
└──────────────────────────────────┘
```

### 5.3.5 User Management (Admin Only)
```
┌──────────────────────────────────┐
│  ◀  KELOLA PENGGUNA     [+]     │
│                                  │
│  AKTIF                           │
│  ┌────────────────────────────┐  │
│  │ [I] Irsad Gufar            │  │
│  │ irsad@email.com            │  │
│  │ [USER]      [Aktif] [⋮]    │  │
│  └────────────────────────────┘  │
│  ┌────────────────────────────┐  │
│  │ [R] rafael Anandi          │  │
│  │ rafael@email.com           │  │
│  │ [HELPDESK]   [Aktif] [⋮]   │  │
│  └────────────────────────────┘  │
│                                  │
│  NONAKTIF                        │
│  ┌────────────────────────────┐  │
│  │ [X] Ex-User                │  │
│  └────────────────────────────┘  │
└──────────────────────────────────┘
```

### 5.3.6 Register Screen

```
┌──────────────────────────────────┐
│  ◀  DAFTAR AKUN BARU             │
│                                  │
│  ┌────────────────────────────┐  │
│  │                            │  │
│  │   [LOGO ETICKETING]        │  │
│  │                            │  │
│  │   Nama Lengkap             │  │
│  │   ┌──────────────────────┐ │  │
│  │   │                      │ │  │
│  │   └──────────────────────┘ │  │
│  │                            │  │
│  │   Email                    │  │
│  │   ┌──────────────────────┐ │  │
│  │   │                      │ │  │
│  │   └──────────────────────┘ │  │
│  │                            │  │
│  │   Password                 │  │
│  │   ┌──────────────────────┐ │  │
│  │   │ ••••••••           👁 │ │  │
│  │   └──────────────────────┘ │  │
│  │   min. 6 karakter          │  │
│  │                            │  │
│  │   ┌──────────────────────┐ │  │
│  │   │      DAFTAR          │ │  │
│  │   └──────────────────────┘ │  │
│  │                            │  │
│  │   Sudah punya akun? Login  │  │
│  │                            │  │
│  └────────────────────────────┘  │
└──────────────────────────────────┘
```

**Behavior:**
- Tap "DAFTAR" → `AuthProvider.register()` → INSERT ke `users` → SnackBar "Akun berhasil dibuat, silakan login" → `context.go('/login')`
- Tap "👁" → toggle `obscureText` pada field password

### 5.3.7 Create Ticket Screen

```
┌──────────────────────────────────┐
│  ◀  BUAT TIKET BARU              │
│                                  │
│  ┌────────────────────────────┐  │
│  │  Judul *                   │  │
│  │  ┌──────────────────────┐  │  │
│  │  │ Contoh: WiFi lemot   │  │  │
│  │  ��──────────────────────┘  │  │
│  │                            │  │
│  │  Kategori *                │  │
│  │  ┌──────────────────────┐  │  │
│  │  │ Hardware         ▼   │  │  │
│  │  └──────────────────────┘  │  │
│  │   ○ hardware ○ software    │  │
│  │   ○ network  ○ other       │  │
│  │                            │  │
│  │  Prioritas *               │  │
│  │  [low] [MEDIUM] [HIGH]     │  │
│  │   abu    orange    red     │  │
│  │                            │  │
│  │  Deskripsi *               │  │
│  │  ┌──────────────────────┐  │  │
│  │  │ Jelaskan masalah...  │  │  │
│  │  │                      │  │  │
│  │  │                      │  │  │
│  │  └──────────────────────┘  │  │
│  │   0/500 karakter           │  │
│  │                            │  │
│  │  ┌──────────────────────┐  │  │
│  │  │     SUBMIT           │  │  │
│  │  └──────────────────────┘  │  │
│  │  ┌──────────────────────┐  │  │
│  │  │     BATAL            │  │  │
│  │  └──────────────────────┘  │  │
│  └────────────────────────────┘  │
└──────────────────────────────────┘
```

**Behavior:**
- Form.validate() wajib semua field * terisi; judul ≥ 5 karakter; deskripsi ≥ 10 karakter
- Tap "SUBMIT" → loading overlay → `TicketProvider.createTicket()` → INSERT ke 3 tabel → pop + SnackBar
- Tap "BATAL" → `Navigator.pop()` tanpa simpan

### 5.3.8 Notification Screen

```
┌──────────────────────────────────┐
│  NOTIFIKASI          ✓✓         │ (✓✓ = tandai semua)
│  ──────────────────────────      │
│  [Semua] [Belum Dibaca]          │ (filter chip)
│  ──────────────────────────      │
│                                  │
│  ┌��───────────────────────────┐  │
│  │ ● Tiket Diubah Status      │  │ (● = belum dibaca)
│  │   T-1729… Anda "Selesai"   │  │
│  │   2 menit lalu         >   │  │
│  └────────────────────────────┘  │
│  ┌────────────────────────────┐  │
│  │ ● Tiket Baru               │  │
│  │   T-1730… dibuat oleh Andri│  │
│  │   10 menit lalu        >   │  │
│  └────────────────────────────┘  │
│  ┌────────────────────────────┐  │
│  │   Komentar Baru            │  │ (tanpa ● = sudah dibaca)
│  │   Helpdesk: "Sedang saya   │  │
│  │   perbaiki WiFi"           │  │
│  │   1 jam lalu           >   │  │
│  └────────────────────────────┘  │
│                                  │
│  ┌────────────────────────────┐  │
│  │   Tiket Ditutup            │  │
│  │   T-1720… ditutup oleh Anda│  │
│  │   kemarin              >   │  │
│  └────────────────────────────┘  │
│                                  │
│  ────────────────                 │
│  [🏠][🎫][🔔 12][👤]            │ (BottomNav, badge di tab)
└──────────────────────────────────┘
```

**Behavior:**
- Tap filter chip "Belum Dibaca" → `is_read = false` query
- Tap "✓✓" → PATCH semua `is_read = true` → SnackBar "Semua ditandai sudah dibaca"
- Tap salah satu notifikasi → `context.push('/tickets/<id>')` → list notification auto-mark `is_read = true`
- Pull-to-refresh → trigger `_loadNotifications()`
- Auto-refresh saat app resume dari background

### 5.3.9 Profile Screen

```
┌──────────────────────────────────┐
│  PROFIL                          │
│  ┌────────────────────────────┐  │
│  │                            │  │
│  │      ┌──────────┐          │  │
│  │      │  [AVATAR]│          │  │
│  │      │  [I]     │          │  │
│  │      └──────────┘          │  │
│  │                            │  │
│  │      Irsad Gufar           │  │
│  │      irsad@email.com       │  │
│  │      [USER]                │  │ (badge role)
│  │                            │  │
│  └────────────────────────────┘  │
│                                  │
│  ┌────────────────────────────┐  │
│  │ 🌙 Mode Gelap            ▶ │  │ (toggle switch on/off)
│  ├────────────────────────────┤  │
│  │ 🔔 Notifikasi            ▶ │  │ (sub-screen kalau ada)
│  ├────────────────────────────┤  │
│  │ 🔒 Ubah Password         ▶ │  │
│  ├────────────────────────────┤  │
│  │ ℹ️  Tentang Aplikasi    ▶ │  │
│  ├────────────────────────────┤  │
│  │ 🚪 Logout               ▶ │  │ (merah)
│  └────────────────────────────┘  │
│                                  │
│  v1.0.0 (build 1)                │
│  © 2026 eTicketing UAS           │
│                                  │
│  ────────────────                 │
│  [🏠][🎫][🔔 0][👤]            │
└──────────────────────────────────┘
```

**Behavior:**
- Tap toggle "Mode Gelap" → `ThemeProvider.toggleTheme()` → save ke SharedPreferences
- Tap "Logout" → dialog konfirmasi → `AuthProvider.logout()` → clear SharedPreferences → `context.go('/login')`
- Badge role ditampilkan dengan warna berbeda: USER (biru), HELPDESK (orange), ADMIN (merah)
- Tombol "Kelola Pengguna" (icon 👥) **hanya muncul** jika `user.role == 'admin'`

## 5.4 Komponen UI Kustom

| Komponen | File | Deskripsi |
|---|---|---|
| `brutalContainer` | `app_theme.dart` | Widget wrapper untuk container dengan border hitam + hard shadow |
| `statusBadge` | `status_badge_widget.dart` | Pill badge warna sesuai status tiket |
| `priorityChip` | (inline) | Chip kecil warna sesuai prioritas |
| `ticketCard` | `ticket_card_widget.dart` | Card tiket untuk list |
| `emptyState` | `empty_widget.dart` | Placeholder untuk list kosong |
| `errorState` | `error_widget.dart` | Placeholder untuk error |
| `loadingState` | `loading_widget.dart` | Loading spinner |

## 5.5 Bottom Navigation

```
┌──────────────────────────────────────────────┐
│  [BERANDA]  [TIKET]  [+]  [INFO]  [PROFIL]   │
└──────────────────────────────────────────────┘
```

4 tab dengan icon + label. Tab aktif = kuning dengan border bawah tebal. Tab non-aktif = hitam/krem.

## 5.6 Dark Mode

Toggle dark mode di Profile → switch. Pakai `ThemeProvider` (ChangeNotifier) yang persist ke `SharedPreferences`. Semua warna otomatis swap lewat `adaptive*()` helpers di `app_theme.dart`:

```dart
static Color adaptiveBackground(BuildContext ctx) =>
    Theme.of(ctx).brightness == Brightness.dark ? backgroundDark : backgroundLight;
```

## 5.7 Accessibility & Responsiveness

- **Tap target minimum 48x48** (Material guideline)
- **Kontras teks AAA** di light mode (hitam di krem)
- **Responsive layout** — pakai `SafeArea` + `Padding` bukan fixed size
- **Pull-to-refresh** di list notifikasi dan tiket
- **Loading state** ditampilkan saat fetch dari Supabase

## 5.8 Interaksi yang Penting

| Gestur/Aksi | Lokasi | Hasil |
|---|---|---|
| Tap kartu tiket | Ticket List | Buka detail |
| Swipe down | Notifikasi / Tiket | Refresh |
| Tap "+" | Tiket List / User Mgmt | Buka form tambah |
| Tap "Ubah Status" | Tiket Detail | Muncul dialog pilihan status (helpdesk+) |
| Tap "Kirim" di komentar | Tiket Detail | Tambah komentar ke DB |
| Tap icon mata | Login | Show/hide password |
| Tap logout | Profile | Konfirmasi dialog → kembali ke Login |

## 5.9 Branding

- **Nama:** eTicketing Helpdesk
- **Tagline (di splash):** "Lapor IT dalam 30 detik"
- **Icon utama:** headset/clipboard dengan huruf "T"
- **Color identity:** kuning Brutalism (paling menonjol, konsisten dengan logo)