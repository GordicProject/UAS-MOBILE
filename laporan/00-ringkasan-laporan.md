# Laporan UAS — Aplikasi eTicketing Helpdesk

> **Mata Kuliah:** Aplikasi Mobile
> **Jenis:** UAS (Ujian Akhir Semester)
> **Aplikasi:** eTicketing Helpdesk — Sistem tiket bantuan internal kantor
> **Versi Dokumen:** 1.0 — Juli 2026

---

## Daftar Isi

| # | Bagian | Topik |
|---|--------|-------|
| 1 | [Ringkasan Eksekutif](#1-ringkasan-eksekutif) | Gambaran umum aplikasi |
| 2 | [Arsitektur & Flow Diagram](#2-arsitektur--flow-diagram) | High-level, MVVM, sequence, use case |
| 3 | [UI / UX Aplikasi](#3-ui--ux-aplikasi) | Layar, design system, navigasi |
| 4 | [Backend API](#4-backend-api) | Supabase PostgREST, endpoint, error handling |
| 5 | [Database](#5-database) | Skema, ERD, relasi, seed data |
| 6 | [Tech Stack](#6-tech-stack) | Flutter, Provider, GoRouter, Supabase |
| 7 | [Sumber Dokumentasi Lengkap](#7-sumber-dokumentasi-lengkap) | Link ke bab per-bab |

---

## 1. Ringkasan Eksekutif

**eTicketing Helpdesk** adalah aplikasi mobile berbasis Flutter yang dipakai karyawan sebuah kantor untuk melaporkan gangguan IT (hardware/software/network). Laporan masuk sebagai tiket, diproses helpdesk, dan diawasi admin.

### Fitur Inti

| Fitur | Deskripsi |
|-------|-----------|
| **Autentikasi** | Login email + password (plain text untuk demo), register, reset password |
| **Buat Tiket** | User/Helpdesk bisa membuat tiket dengan kategori & prioritas |
| **Antrian Tiket** | List tiket dengan filter status, sort by prioritas |
| **Detail Tiket** | Lihat deskripsi, komentar, history perubahan, attachment |
| **Update Status** | Helpdesk/Admin bisa ubah `open` → `inProgress` → `resolved` → `closed` |
| **Assign Tiket** | Helpdesk bisa claim tiket ke diri sendiri |
| **Komentar** | Semua role bisa komentar di tiket manapun |
| **Notifikasi In-App** | Badge unread di bottom-nav, list notifikasi, mark-as-read |
| **User Management** | Admin bisa CRUD user, ubah role, aktif/nonaktif akun |
| **Dark Mode** | Toggle light/dark mode, tersimpan di SharedPreferences |
| **Upload Attachment** | Ambil foto dari kamera/galeri, atau pilih file |

### 3 Role Pengguna

| Role | Hak Akses |
|------|-----------|
| **User** | Buat tiket, lihat tiket sendiri, komentar di tiket sendiri |
| **Helpdesk** | Semua hak user + lihat semua tiket, ubah status, assign tiket |
| **Admin** | Semua hak helpdesk + kelola user (CRUD, ubah role, aktif/nonaktif) |

### Akun Demo (Password: `123`)

| Email | Nama | Role |
|-------|------|------|
| `irsad@email.com` | Irsad Gufar | user |
| `azzam@email.com` | Abdullah Azzam | user |
| `rafael@email.com` | rafael Anandi | helpdesk |
| `dewi@email.com` | Dewi Chumairoh | helpdesk |
| `admin@email.com` | Admin | admin |

---

## 2. Arsitektur & Flow Diagram

### 2.1 Arsitektur High-Level

```
┌────────────────────────────────────────────────────────┐
│                    FLUTTER APP                          │
│                                                         │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌─────────┐ │
│  │ Screens  │→ │Providers │→ │ Services │→ │Supabase │ │
│  │ (View)   │  │(ViewModel│  │(Repo)    │  │ Client  │ │
│  └──────────┘  └──────────┘  └──────────┘  └────┬────┘ │
│       ↑                ↑              ↑             │    │
│       └────────────────┴──────────────┘             │    │
│            ChangeNotifier + GoRouter                │    │
└───────────────────────────────────────────────────┼────┘
                                                    │ HTTPS
                                                    ▼
                                          ┌─────────────────┐
                                          │   SUPABASE      │
                                          │  ┌───────────┐  │
                                          │  │PostgreSQL │  │
                                          │  └───────────┘  │
                                          │  ┌───────────┐  │
                                          │  │  Storage  │  │
                                          │  └───────────┘  │
                                          └─────────────────┘
```

**Prinsip desain:**
- **Single source of truth** — state aplikasi hanya di Provider, UI hanya membaca lewat `Consumer`.
- **Stateless widget** sebanyak mungkin — logika ada di Provider/Service.
- **Repository pattern** — semua panggilan Supabase melewati `SupabaseService` (singleton).
- **Optimistic UI** — untuk update ringan, UI update dulu sambil sinkron ke server di background.

### 2.2 Alur Data End-to-End

1. User tap tombol / input teks di **Screen** (View).
2. Screen panggil method di **Provider** (ViewModel), mis. `TicketProvider.createTicket()`.
3. Provider bungkus jadi loading state + delegasi ke **Service** (Repository).
4. Service panggil Supabase REST/PostgREST API lewat `supabase_flutter` SDK.
5. Hasil (data atau error) kembalikan ke Provider, lalu Provider `notifyListeners()`.
6. Screen yang pakai `Consumer<...>` otomatis re-build dan tampilkan data baru.

### 2.3 Arsitektur MVVM

| Layer | Tanggung Jawab | Contoh File |
|-------|----------------|-------------|
| **Model** | Struktur data + serialisasi JSON | `data/models/ticket_model.dart` |
| **View** | Widget UI, tampilan saja, no logic | `presentation/screens/tickets/ticket_list_screen.dart` |
| **ViewModel** | State management + business logic | `presentation/providers/ticket_provider.dart` |
| **Service** | Akses data eksternal (Supabase) | `services/supabase_service.dart` |

### 2.4 Sequence Diagram — Buat Tiket

```
User          Screen           Provider          SupabaseService     Supabase
 │              │                  │                    │                │
 │ tap "+Buat"  │                  │                    │                │
 ├─────────────>│                  │                    │                │
 │              │ createTicket()   │                    │                │
 │              ├─────────────────>│                    │                │
 │              │                  │ createTicket(...)  │                │
 │              │                  ├───────────────────>│                │
 │              │                  │                    │ INSERT ticket  │
 │              │                  │                    ├───────────────>│
 │              │                  │                    │ INSERT history │
 │              │                  │                    ├───────────────>│
 │              │                  │                    │ UPSERT notif   │
 │              │                  │                    ├───────────────>│
 │              │                  │                    │<──── ok ───────┤
 │              │                  │<──── success ──────┤                │
 │              │                  │ notifyListeners()  │                │
 │              │<─── rebuild ─────┤                    │                │
 │<─── show ────│                  │                    │                │
 │   snackbar   │                  │                    │                │
```

### 2.5 Flow Ubah Status Tiket

```
Helpdesk buka detail tiket
  │
  ▼
Tap tombol "Ubah Status" (dropdown)
  │
  ├──> Pilih "In Progress"
  │      │
  │      ├──> updateTicketStatus(status: inProgress, note: "...")
  │      │     │
  │      │     ├──> UPDATE tickets SET status=..., updated_at=...
  │      │     ├──> INSERT ticket_history (audit trail)
  │      │     └──> UPSERT notifications (info ke user)
  │      │
  │      └──> UI refresh otomatis via notifyListeners()
  │
  ├──> Pilih "Resolved"
  │      └──> sama seperti di atas, status: resolved
  │
  └──> Pilih "Closed"
         └──> sama seperti di atas, status: closed
```

### 2.6 Use Case Diagram (Ringkas)

| ID | Nama | Aktor |
|----|------|-------|
| UC01 | Login | Semua |
| UC02 | Register | Siapa saja |
| UC03 | Buat Tiket | User, Helpdesk |
| UC04 | Lihat Detail Tiket | Semua |
| UC05 | Komentar di Tiket | Semua |
| UC06 | Lihat Notifikasi | Semua |
| UC07 | Tandai Semua Dibaca | Semua |
| UC08 | Lihat Daftar Tiket | Semua (scope beda per role) |
| UC09 | Ubah Status Tiket | Helpdesk, Admin |
| UC10 | Assign Tiket ke Diri Sendiri | Helpdesk, Admin |
| UC11 | Lihat Semua Tiket (cross-user) | Helpdesk, Admin |
| UC12 | Toggle Dark Mode | Semua |
| UC13 | Kelola Akun User | Admin only |

### 2.7 Diagram Lengkap (Render PNG)

Seluruh diagram tersedia di folder `diagrams/` dengan source Mermaid:

| # | Nama | File PNG |
|---|------|----------|
| 1 | Arsitektur High-Level | `02-1-hl.png` |
| 2 | Alur Data | `02-2-fix.png` |
| 3 | MVVM Sequence | `02-3-fix.png` |
| 4 | Flow Buat Tiket | `02-4-fix.png` |
| 5 | Flow Ubah Status | `02-5-fix.png` |
| 6 | Flow Notifikasi | `02-6-fix.png` |
| 7 | Struktur Folder | `02-7-fix.png` |
| 8 | Routing GoRouter | `02-8-fix.png` |
| 9-10 | Lifecycle State | `02-9-fix.png`, `02-10-fix.png` |
| 11 | Use Case | `02-11-fix.png` |
| 12 | Activity Buat-Tiket-Selesai | `02-12-fix.png` |
| 13 | Component Diagram | `02-13-fix.png` |
| 14 | Login Flow | `flow-login.png` |

---

## 3. UI / UX Aplikasi

### 3.1 Design Language: Neo-Brutalism

| Prinsip | Implementasi |
|---------|--------------|
| **Warna bold** | Kuning `#FFD700`, pink `#FF3D7F`, orange `#FF7A00`, lime `#73F74D` |
| **Border hitam tebal** | 3-4px black border di setiap container |
| **Hard shadow** | `BoxShadow` offset (4,4) blur 0 |
| **Tipografi block letter** | `Space Grotesk` weight 800-900 |
| **Kontras tinggi** | Hitam pekat di atas kuning/krem |
| **Tanpa gradien** | Warna flat, tegas |
| **Tanpa border-radius besar** | Hanya 2-4px radius |

### 3.2 Palette Warna

```
LIGHT MODE                              DARK MODE
  Background:    #FFF6E0 (krem)          Background:    #0D0D0D
  Surface:       #FFFFFF                 Surface:       #1E1E1E
  Text:          #000000                 Text:          #FFFBF0
  Border:        #000000                 Border:        #FFFBF0
  Primary:       #FFD700 (kuning)        Primary:       #FFD700 (tetap)
```

### 3.3 Status & Priority Colors

| Status | Color | Hex |
|--------|-------|-----|
| `open` | Pink Neon | `#FF3D7F` |
| `inProgress` | Orange | `#FF7A00` |
| `resolved` | Lime Green | `#73F74D` |
| `closed` | Abu-abu | `#C0C0C0` |

### 3.4 Daftar 14 Layar

| # | Layar | File | Akses |
|---|-------|------|-------|
| 1 | Splash | `splash_screen.dart` | Semua |
| 2 | Login | `login_screen.dart` | Sebelum login |
| 3 | Register | `register_screen.dart` | User baru |
| 4 | Reset Password | `reset_password_screen.dart` | Lupa password |
| 5 | Main Shell (BottomNav) | `main_shell.dart` | Sudah login |
| 6 | Dashboard | `dashboard_screen.dart` | Tab 1 (semua role) |
| 7 | Tiket List | `ticket_list_screen.dart` | Tab 2 (semua role) |
| 8 | Tiket Detail | `ticket_detail_screen.dart` | Semua |
| 9 | Buat Tiket | `create_ticket_screen.dart` | User, Helpdesk |
| 10 | Notifikasi | `notification_screen.dart` | Tab 3 (semua role) |
| 11 | Profile | `profile_screen.dart` | Tab 4 (Helpdesk) / Tab 5 (Admin) |
| 12 | User Management | `admin/user_management_screen.dart` | Admin only |
| 13 | Add User (dialog) | (di dalam #12) | Admin only |
| 14 | Edit User (dialog) | (di dalam #12) | Admin only |

### 3.5 Navigasi Bottom (Bottom Navigation)

```
┌──────────────────────────────────────────────────┐
│                                                  │
│              [Konten Layar Aktif]                │
│                                                  │
├──────────────────────────────────────────────────┤
│   🏠          📋           🔔            👤       │
│ Beranda     Tiket    Notifikasi      Profil      │
│                                          (⚙️Admin)│
└──────────────────────────────────────────────────┘
```

- **Tab 1 — Beranda (Dashboard):** greeting, statistik tiket, chart
- **Tab 2 — Tiket:** list tiket (scope beda per role) + tombol `+ Buat`
- **Tab 3 — Notifikasi:** list notifikasi + badge unread + "Tandai semua dibaca"
- **Tab 4 — Profil:** info user, toggle dark mode, logout (Helpdesk)
- **Tab 5 — Profil:** + menu "Kelola Pengguna" (Admin only)

### 3.6 Wireframe Login

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

### 3.7 Wireframe Dashboard

```
┌──────────────────────────────────┐
│  HELLO, BUDI                     │
│  Anda memiliki 3 tiket aktif     │
│                                  │
│  ┌──────┐ ┌──────┐ ┌──────┐      │
│  │ OPEN │ │INPROG│ │RESOLV│      │
│  │  2   │ │  1   │ │  4   │      │
│  └──────┘ └──────┘ └──────┘      │
│                                  │
│  ┌────────────────────────────┐  │
│  │  CHART: Tiket per Status   │  │
│  │  ▇▇▇▇                     │  │
│  │  ▇▇▇                       │  │
│  │  ▇▇▇▇▇▇                    │  │
│  └────────────────────────────┘  │
│                                  │
│  Tiket Terbaru                   │
│  ┌────────────────────────────┐  │
│  │ TK-001  [HIGH] [OPEN]      │  │
│  │ Laptop sering hang         │  │
│  └────────────────────────────┘  │
└──────────────────────────────────┘
```

### 3.8 Wireframe Tiket Detail

```
┌──────────────────────────────────┐
│ <  Tiket TK-001                  │
│                                  │
│  Laptop sering hang              │
│  Dibuat: 1 Jul 2026              │
│  ┌─────────────────────────────┐ │
│  │ [HIGH] [IN PROGRESS]        │ │
│  │ Kategori: hardware          │ │
│  │ Dibuat oleh: Budi           │ │
│  │ Ditugaskan ke: Rizky        │ │
│  └─────────────────────────────┘ │
│                                  │
│  Deskripsi:                      │
│  Laptop Lenovo saya selalu hang  │
│  kalau buka Chrome + Excel...    │
│                                  │
│  Riwayat:                        │
│  • 1 Jul — Tiket dibuat          │
│  • 2 Jul — inProgress            │
│                                  │
│  Komentar:                       │
│  [Rizky]: Sudah dicek, perlu    │
│  upgrade RAM ke 8GB.            │
│                                  │
│  ┌────────────────────────────┐  │
│  │ Tulis komentar...          │  │
│  │                       [➤] │  │
│  └────────────────────────────┘  │
│                                  │
│  ┌────────────────────────────┐  │
│  │     UBAH STATUS            │  │  (helpdesk/admin)
│  └────────────────────────────┘  │
│  ┌────────────────────────────┐  │
│  │   ASSIGN KE DIRI SENDIRI   │  │  (helpdesk)
│  └────────────────────────────┘  │
└──────────────────────────────────┘
```

### 3.9 Flow Navigasi (Ringkas)

```
┌──────────┐     ┌──────────┐
│  Splash  │────>│  Login   │
└──────────┘     └────┬─────┘
                      │ register
                      ▼
                 ┌──────────┐
                 │ Register │
                 └──────────┘

  Setelah login sukses:
  ┌──────────────────────────────────────┐
  │              MainShell               │
  │  ┌────┐ ┌────┐ ┌────┐ ┌────┐ ┌────┐  │
  │  │ 🏠 │ │ 📋 │ │ 🔔 │ │ 👤 │ │ ⚙️ │  │
  │  └────┘ └─┬──┘ └────┘ └────┘ └────┘  │
  └───────────┼──────────────────────────┘
              │
              ├──> /create-ticket  (tombol +)
              ├──> /tickets/:id    (tap card)
              └──> /admin/users    (admin only)
```

### 3.10 Guards di GoRouter

| Path | Guard |
|------|-------|
| `/splash`, `/login`, `/register`, `/reset-password` | Hanya untuk **belum login** |
| `/dashboard`, `/tickets`, `/notifications`, `/profile` | Wajib **sudah login** |
| `/admin/users` | Wajib login **+ role = admin** |
| `/create-ticket` | Wajib login **+ role = user atau helpdesk** (admin juga boleh) |

---

## 4. Backend API

### 4.1 Platform: Supabase PostgREST

eTicketing tidak punya backend custom — semua operasi database dilakukan via **Supabase Client SDK** (`supabase_flutter`), yang berbicara dengan **PostgREST API** Supabase:

```
Dart: _db.from('tickets').select('*').eq('status', 'open')
     ↓
HTTP: GET https://eblilamcydtnafqhzcxa.supabase.co/rest/v1/tickets?select=*&status=eq.open
     ↓
Postgres: SELECT * FROM tickets WHERE status = 'open'
```

**Base URL:** `https://eblilamcydtnafqhzcxa.supabase.co/rest/v1/`
**Header wajib:**
- `apikey: <anon_key>`
- `Authorization: Bearer <anon_key>`
- `Content-Type: application/json`

### 4.2 Endpoint — Tabel `users`

| Operasi | HTTP | URL Pattern | Method di Kode |
|---------|------|-------------|----------------|
| Login | `GET` | `/users?email=eq.X&password=eq.Y` | `SupabaseService.login()` |
| Get all | `GET` | `/users?select=*` | `SupabaseService.getAllUsers()` |
| Get by id | `GET` | `/users?id=eq.X` | `SupabaseService.getUserById()` |
| Create | `POST` | `/users` body JSON | `SupabaseService.createUser()` |
| Update role | `PATCH` | `/users?id=eq.X` | `SupabaseService.updateUserRole()` |
| Soft delete | `PATCH` | `/users?id=eq.X` | `SupabaseService.deactivateUser()` |
| Reactivate | `PATCH` | `/users?id=eq.X` | `SupabaseService.activateUser()` |
| Hard delete | `DELETE` | `/users?id=eq.X` | `SupabaseService.deleteUser()` |

### 4.3 Endpoint — Tabel `tickets`

| Operasi | HTTP | URL Pattern |
|---------|------|-------------|
| Get all (+ relasi) | `GET` | `/tickets?select=*,comments(*),ticket_history(*),ticket_attachments(*)&order=created_at.desc` |
| Get by user | `GET` | `/tickets?created_by=eq.X&select=...&order=...` |
| Get by assignee | `GET` | `/tickets?assigned_to=eq.X&select=...&order=...` |
| Create | `POST` | `/tickets` |
| Update status | `PATCH` | `/tickets?id=eq.X` |

### 4.4 Endpoint — Tabel `comments`, `ticket_history`, `notifications`

| Tabel | Operasi | HTTP | URL |
|-------|---------|------|-----|
| `comments` | Create | `POST` | `/comments` |
| `comments` | Read | - | (otomatis via parent `tickets?select=...,comments(*)`) |
| `ticket_history` | Create | `POST` | `/ticket_history` |
| `ticket_history` | Read | - | (otomatis via parent) |
| `notifications` | Get all | `GET` | `/notifications?select=...&order=created_at.desc` |
| `notifications` | Add | `POST` | `/notifications` (upsert by id) |
| `notifications` | Mark read | `PATCH` | `/notifications?id=eq.X` body `{is_read:true}` |
| `notifications` | Mark all | `PATCH` | `/notifications?is_read=eq.false` body `{is_read:true}` |

### 4.5 Endpoint — Attachment (Storage)

| Operasi | HTTP | URL |
|---------|------|-----|
| Create row | `POST` | `/ticket_attachments` |
| Upload file | `POST` | `/storage/v1/object/attachments/<path>` (binary) |
| Get public URL | `GET` | `/storage/v1/object/public/attachments/<path>` |

### 4.6 Snippet Kode — SupabaseService

```dart
// lib/services/supabase_service.dart
class SupabaseService {
  final _db = Supabase.instance.client;

  Future<UserModel?> login(String email, String password) async {
    final res = await _db
        .from('users')
        .select('id, name, email, password, role, avatar_url, created_at, is_active')
        .eq('email', email)
        .eq('password', password)
        .maybeSingle();
    if (res == null) return null;
    final user = UserModel.fromJson(res);
    if (user.isActive == false) return null;   // tolak user nonaktif
    return user;
  }

  Future<void> createTicket({
    required String id,
    required String title,
    required String description,
    required TicketCategory category,
    required TicketPriority priority,
    required String createdBy,
  }) async {
    await _db.from('tickets').insert({
      'id':          id,
      'title':       title,
      'description': description,
      'category':    category.name,
      'priority':    priority.name,
      'status':      TicketStatus.open.name,
      'created_by':  createdBy,
    });
    // Otomatis tambah history pertama
    await _db.from('ticket_history').insert({
      'ticket_id': id,
      'status':    TicketStatus.open.name,
      'note':      'Tiket dibuat',
    });
  }

  Future<void> updateTicketStatus({...}) async {
    final update = {'status': status.name, 'updated_at': DateTime.now().toIso8601String()};
    if (assignedTo != null) update['assigned_to'] = assignedTo;
    await _db.from('tickets').update(update).eq('id', ticketId);
    await _db.from('ticket_history').insert({...});
    await _service.addNotification(...);  // trigger notif
  }
}
```

### 4.7 Trigger Notifikasi Otomatis

Di implementasi saat ini, notifikasi dibuat oleh `TicketProvider` setelah operasi utama berhasil. Pola: simpan data utama dulu, lalu insert notifikasi terpisah.

| Aksi | Tipe Notifikasi |
|------|-----------------|
| Buat tiket baru | `'Tiket T-... Dibuat'` |
| Ubah status tiket | `'Status Tiket T-... Berubah'` |
| Tambah komentar | `'Komentar Baru di Tiket T-...'` |
| Assign tiket ke helpdesk | `'Tiket T-... Ditugaskan'` |
| Admin tambah user | `'Pengguna Baru Ditambahkan'` |
| Admin hapus user | `'Pengguna Dihapus'` |
| Admin aktif/nonaktif user | `'Pengguna Diaktifkan/Dinonaktifkan'` |
| Admin ubah role | `'Role Pengguna Diubah'` |

### 4.8 Error Handling

```dart
try {
  await SupabaseService().login(email, password);
} on PostgrestException catch (e) {
  // error dari Supabase (mis. RLS denied, constraint violation)
  showSnackBar(e.message);
} on SocketException {
  // tidak ada internet
  showSnackBar('Tidak ada koneksi internet');
} catch (e) {
  // unknown error
  showSnackBar('Error: $e');
}
```

Notifikasi dibuat **di dalam try-catch dengan swallow** — kalau gagal insert notif, alur utama tidak boleh gagal:
```dart
try {
  await SupabaseService().addNotification(...);
} catch (_) { /* notif gagal jangan block alur */ }
```

### 4.9 Kuota & Limit (Free Tier)

| Resource | Free Tier | Penggunaan |
|----------|-----------|------------|
| Database size | 500 MB | < 1 MB |
| Storage | 1 GB | < 10 MB |
| Bandwidth | 2 GB/bulan | < 50 MB |
| Realtime connections | 200 concurrent | - |
| Edge functions | 500k/bulan | 0 |

Untuk UAS demo, **free tier lebih dari cukup**.

### 4.10 Realtime (Future)

Saat ini tidak ada subscription realtime — user harus pull-to-refresh atau buka ulang tab. Untuk production bisa pakai Supabase Realtime:
```dart
final sub = _db
  .from('notifications')
  .stream(primaryKey: ['id'])
  .listen((rows) {
    // update UI otomatis
  });
```

---

## 5. Database

### 5.1 Platform

**Supabase** (Postgres 15) — cloud-hosted. Project ref: `eblilamcydtnafqhzcxa`.
URL region: Asia (Singapore). Akses via:
- **Supabase Dashboard:** https://supabase.com/dashboard/project/eblilamcydtnafqhzcxa
- **Anon key (publik):** ada di `lib/core/supabase_config.dart` (RLS di-disable untuk dev).

Database ini menyimpan **6 tabel utama** untuk eTicketing Helpdesk.

### 5.2 Daftar Tabel

| # | Tabel | Fungsi | Estimasi Rows |
|---|-------|--------|---------------|
| 1 | `users` | Akun pengguna + role | < 1.000 |
| 2 | `tickets` | Laporan tiket | < 10.000 |
| 3 | `comments` | Komentar di tiket | < 100.000 |
| 4 | `ticket_history` | Audit trail perubahan status | < 50.000 |
| 5 | `notifications` | Notifikasi in-app | < 50.000 |
| 6 | `ticket_attachments` | File attachment URL | < 10.000 |

### 5.3 ERD (Entity Relationship Diagram)

```
   ┌──────────┐
   │  USERS   │
   │ id (PK)  │
   │ name     │
   │ email    │
   │ password │
   │ role     │
   │ avatar   │
   │ is_active│
   └────┬─────┘
        │ 1
        │
        │ N
   ┌────▼──────────┐         ┌─────────────────────┐
   │   TICKETS     │ 1     N │   TICKET_HISTORY    │
   │ id (PK)       ├─────────┤ id (PK)             │
   │ title         │         │ ticket_id (FK)      │
   │ description   │         │ status              │
   │ category      │         │ changed_at          │
   │ priority      │         │ note                │
   │ status        │         └─────────────────────┘
   │ created_by(FK)│
   │ assigned_to   │ 1
   │ created_at    │ N        ┌─────────────────────┐
   │ updated_at    ├─────────┤     COMMENTS        │
   └────┬──────────┘         │ id (PK)             │
        │ 1                  │ ticket_id (FK)      │
        │                    │ user_id (FK)        │
        │ N                  │ user_name (snapshot)│
   ┌────▼──────────┐         │ content             │
   │  NOTIFICATIONS│         │ created_at          │
   │ id (PK)       │         └─────────────────────┘
   │ title         │
   │ message       │         ┌─────────────────────┐
   │ ticket_id(FK) │         │  TICKET_ATTACHMENTS │
   │ is_read       │         │ id (PK)             │
   │ created_at    │ 1     N │ ticket_id (FK)      │
   └───────────────┘◄────────┤ file_url            │
                            │ file_name           │
                            │ created_at          │
                            └─────────────────────┘
```

### 5.4 Skema Lengkap (sesuai `database_setup.sql`)

```sql
-- ── 1. USERS ──────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS users (
  id          UUID         PRIMARY KEY,
  name        TEXT         NOT NULL,
  email       TEXT         NOT NULL UNIQUE,
  password    TEXT         NOT NULL,                -- plain text (untuk demo UAS)
  role        TEXT         NOT NULL CHECK (role IN ('user', 'helpdesk', 'admin')),
  avatar_url  TEXT,
  created_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  is_active   BOOLEAN      DEFAULT TRUE            -- soft-delete flag
);

-- ── 2. TICKETS ────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS tickets (
  id           TEXT         PRIMARY KEY,           -- "TK-001" atau "T-1720..."
  title        TEXT         NOT NULL,
  description  TEXT,
  category     TEXT         NOT NULL CHECK (category IN ('hardware', 'software', 'network', 'other')),
  priority     TEXT         NOT NULL CHECK (priority IN ('low', 'medium', 'high')),
  status       TEXT         NOT NULL DEFAULT 'open'
                            CHECK (status IN ('open', 'inProgress', 'resolved', 'closed')),
  created_by   UUID         NOT NULL REFERENCES users(id),
  assigned_to  UUID         REFERENCES users(id),  -- nullable
  created_at   TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  updated_at   TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

-- ── 3. COMMENTS ───────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS comments (
  id          TEXT         PRIMARY KEY,            -- "cm-01" atau "cm-<uuid>"
  ticket_id   TEXT         NOT NULL REFERENCES tickets(id) ON DELETE CASCADE,
  user_id     UUID         NOT NULL REFERENCES users(id),
  user_name   TEXT         NOT NULL,               -- snapshot nama
  content     TEXT         NOT NULL,
  created_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

-- ── 4. TICKET HISTORY ─────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS ticket_history (
  id          UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
  ticket_id   TEXT         NOT NULL REFERENCES tickets(id) ON DELETE CASCADE,
  status      TEXT         NOT NULL,
  changed_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  note        TEXT
);

-- ── 5. NOTIFICATIONS ──────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS notifications (
  id          TEXT         PRIMARY KEY,
  title       TEXT         NOT NULL,
  message     TEXT         NOT NULL,
  ticket_id   TEXT         REFERENCES tickets(id), -- nullable (notif sistem)
  is_read     BOOLEAN      NOT NULL DEFAULT FALSE,
  created_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

-- ── 6. ATTACHMENTS ────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS ticket_attachments (
  id          UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
  ticket_id   TEXT         NOT NULL REFERENCES tickets(id) ON DELETE CASCADE,
  file_url    TEXT         NOT NULL,
  file_name   TEXT,
  created_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

-- RLS di-disable untuk development
ALTER TABLE users             DISABLE ROW LEVEL SECURITY;
ALTER TABLE tickets           DISABLE ROW LEVEL SECURITY;
ALTER TABLE comments          DISABLE ROW LEVEL SECURITY;
ALTER TABLE ticket_history    DISABLE ROW LEVEL SECURITY;
ALTER TABLE notifications     DISABLE ROW LEVEL SECURITY;
ALTER TABLE ticket_attachments DISABLE ROW LEVEL SECURITY;
```

### 5.5 Relasi Antar Tabel

| Relasi | Tipe | Keterangan |
|--------|------|------------|
| `users` → `tickets.created_by` | 1-to-N | Satu user bisa membuat banyak tiket |
| `users` → `tickets.assigned_to` | 1-to-N (nullable) | Satu helpdesk bisa handle banyak tiket |
| `users` → `comments.user_id` | 1-to-N | Satu user bisa komentar di banyak tiket |
| `tickets` → `comments` | 1-to-N | `ON DELETE CASCADE` — tiket dihapus, komentar ikut hilang |
| `tickets` → `ticket_history` | 1-to-N | `ON DELETE CASCADE` — tiket dihapus, history ikut hilang |
| `tickets` → `notifications.ticket_id` | 1-to-N (nullable) | Notif sistem boleh tanpa tiket |
| `tickets` → `ticket_attachments` | 1-to-N | `ON DELETE CASCADE` |

### 5.6 Konvensi ID Tiket

Field `tickets.id` bertipe **TEXT** (bukan UUID), supaya bisa pakai format yang mudah dibaca:

- **Seed data** (di `database_setup.sql`): format `TK-001`, `TK-002`, ... `TK-006` — mudah dibaca manusia.
- **Runtime** (di `lib/presentation/providers/ticket_provider.dart`): saat user membuat tiket baru, ID di-generate sebagai `'T-${DateTime.now().millisecondsSinceEpoch}'`, contoh: `T-1720234567890` — unik berbasis timestamp, anti-duplikat walau tanpa UUID generator.

### 5.7 Seed Data (Ringkas)

```sql
-- 5 USERS (semua password = "123")
INSERT INTO users (id, name, email, password, role, is_active) VALUES
  ('a0000000-0000-0000-0000-000000000001', 'Irsad Gufar',     'irsad@email.com',  '123', 'user',     TRUE),
  ('a0000000-0000-0000-0000-000000000002', 'Abdullah Azzam',  'azzam@email.com',  '123', 'user',     TRUE),
  ('a0000000-0000-0000-0000-000000000003', 'rafael Anandi',   'rafael@email.com', '123', 'helpdesk', TRUE),
  ('a0000000-0000-0000-0000-000000000004', 'Dewi Chumairoh',  'dewi@email.com',   '123', 'helpdesk', TRUE),
  ('a0000000-0000-0000-0000-000000000005', 'Admin',           'admin@email.com',  '123', 'admin',    TRUE);

-- 6 TICKETS (campur status: open, inProgress, resolved, closed)
INSERT INTO tickets (id, title, description, category, priority, status, created_by, assigned_to) VALUES
  ('TK-001', 'Laptop sering hang saat buka banyak aplikasi', 'Lenovo hang...', 'hardware', 'high',   'inProgress', '<budi>',  '<rizky>'),
  ('TK-002', 'Tidak bisa print ke printer kantor lantai 3',  'HP LaserJet...', 'software', 'medium', 'open',       '<siti>',  NULL),
  ('TK-003', 'WiFi drop setiap jam 10 pagi',                 'AP lantai 3...', 'network',  'high',   'resolved',   '<budi>',  '<dewi>'),
  ('TK-004', 'Access VPN tidak bisa login',                  'Cisco VPN...',   'network',  'high',   'inProgress', '<siti>',  '<rizky>'),
  ('TK-005', 'Install Office 365 untuk kerja jarak jauh',    'Mohon install...','software', 'low',    'closed',     '<budi>',  '<rizky>'),
  ('TK-006', 'Monitor LCD rusak pixel mati',                 'Dell bergaris...','hardware', 'medium', 'open',       '<siti>',  NULL);
```

Total seed: **5 user, 6 tiket, 3 komentar, 11 history entry, 5 notifikasi**.

---

## 6. Tech Stack

| Layer | Teknologi | Versi | Alasan |
|-------|-----------|-------|--------|
| **Framework** | Flutter | 3.x | Single codebase, hot reload cepat, paket UI lengkap |
| **Bahasa** | Dart | >=3.0.0 | Native Flutter |
| **Backend Cloud** | Supabase | 2.3.0 | Postgres SQL (familiar), free tier cukup, RLS built-in |
| **State Management** | Provider | 6.1.1 | Paling sederhana, bawaan flutter, dokumentasi lengkap |
| **Routing** | GoRouter | 13.0.0 | URL-style routing, cocok untuk deep link |
| **HTTP** | supabase_flutter | 2.3.0 | SDK resmi Supabase |
| **Charts** | fl_chart | 0.68.0 | Chart di dashboard (pie/bar) |
| **Date Format** | intl | 0.19.0 | Format tanggal Indonesia |
| **Relative Time** | timeago | 3.6.0 | "2 jam lalu" |
| **Image Picker** | image_picker | 1.1.2 | Ambil foto dari kamera/galeri |
| **File Picker** | file_picker | 8.1.2 | Pilih file attachment |
| **Font** | google_fonts | 6.2.1 | Font Space Grotesk (neo-brutalism) |
| **UUID** | uuid | 4.4.0 | Generate ID user baru |

### Struktur Folder

```
eTicketing/
├── lib/
│   ├── main.dart                          # entry point + init Supabase
│   ├── core/
│   │   ├── supabase_config.dart           # URL + anon key
│   │   ├── theme/app_theme.dart           # ThemeData light + dark
│   │   ├── router/app_router.dart         # GoRouter config
│   │   └── utils/validators.dart          # form validators
│   ├── data/
│   │   ├── models/                        # UserModel, TicketModel, NotificationModel
│   │   └── dummy/dummy_data.dart          # data dummy untuk testing
│   ├── services/
│   │   └── supabase_service.dart          # semua akses Supabase
│   └── presentation/
│       ├── providers/                     # AuthProvider, ThemeProvider, TicketProvider
│       ├── screens/                       # 14 layar (login, dashboard, dll)
│       └── widgets/                       # widget reusable (status_badge, ticket_card, dll)
├── database_setup.sql                     # CREATE TABLE + seed data
├── database_drop.sql                      # DROP TABLE script
├── SUPABASE_SETUP.md                      # cara setup project Supabase
└── pubspec.yaml                           # dependencies
```

---

## 7. Sumber Dokumentasi Lengkap

Dokumen ini adalah **ringkasan** dari 9 bab dokumentasi lengkap yang lebih detail:

| # | Bab | File | Isi Detail |
|---|-----|------|------------|
| 1 | Pendahuluan | `01-pendahuluan.md` | Latar belakang, tujuan, scope, user persona, metodologi |
| 2 | Arsitektur | `02-arsitektur.md` | High-level, MVVM, sequence diagram, use case, lifecycle |
| 3 | Database | `03-database.md` | Skema lengkap, ERD, relasi, seed, RLS |
| 4 | Backend API | `04-api.md` | Endpoint PostgREST per tabel, error handling, kuota |
| 5 | UI/UX | `05-uiux.md` | 14 layar, wireframe ASCII, design system neo-brutalism |
| 6 | Fitur | `06-fitur.md` | Fitur per role (user/helpdesk/admin) |
| 7 | Video Tutorial | `07-video-tutorial.md` | Script screencast scene-by-scene |
| 8 | Panduan Deploy | `08-panduan-deploy.md` | Install Flutter, setup Supabase, run app |
| 9 | Dokumentasi Kode | `09-dokumentasi-kode.md` | Struktur folder, modul penting, snippet penting |

**Cara generate DOCX/PDF:**
```bash
cd "eTicketing/laporan"
python build_docx.py        # Markdown → DOCX
# (opsional) DOCX → PDF via Microsoft Word COM
```

Output akhir:
- `Laporan_UAS_eTicketing_Helpdesk.docx` (~110 KB)
- Diagram di folder `diagrams/` (15 PNG)

---

*Disusun sebagai tugas UAS Teori — Aplikasi Mobile, Semester 4.*
