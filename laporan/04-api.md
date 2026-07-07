# 04 — Backend API

## 4.1 Arsitektur Backend

eTicketing tidak punya backend custom — semua operasi database dilakukan via **Supabase Client SDK** (`supabase_flutter`), yang berbicara dengan **PostgREST API** Supabase. Setiap query Dart diterjemahkan jadi HTTP request:

```
Dart: _db.from('tickets').select('*').eq('status', 'open')
     ↓
HTTP: GET https://eblilamcydtnafqhzcxa.supabase.co/rest/v1/tickets?select=*&status=eq.open
     ↓
Postgres: SELECT * FROM tickets WHERE status = 'open'
```

## 4.2 Endpoint yang Dipakai (REST via PostgREST)

URL base: `https://eblilamcydtnafqhzcxa.supabase.co/rest/v1/`

Header wajib:
- `apikey: <anon_key>`
- `Authorization: Bearer <anon_key>`
- `Content-Type: application/json`

### 4.2.1 Tabel `users`

| Operasi | HTTP Method | URL Pattern | Digunakan Oleh |
|---|---|---|---|
| Login | `GET` | `/users?email=eq.X&password=eq.Y&select=*` | `SupabaseService.login()` |
| Get all | `GET` | `/users?select=*` | `SupabaseService.getAllUsers()` |
| Get by id | `GET` | `/users?id=eq.X&select=*` | `SupabaseService.getUserById()` |
| Create | `POST` | `/users` body JSON | `SupabaseService.createUser()` |
| Update role | `PATCH` | `/users?id=eq.X` body `{role:...}` | `SupabaseService.updateUserRole()` |
| Soft delete | `PATCH` | `/users?id=eq.X` body `{is_active:false}` | `SupabaseService.deactivateUser()` |
| Reactivate | `PATCH` | `/users?id=eq.X` body `{is_active:true}` | `SupabaseService.activateUser()` |
| Hard delete | `DELETE` | `/users?id=eq.X` | `SupabaseService.deleteUser()` |

### 4.2.2 Tabel `tickets`

| Operasi | HTTP Method | URL Pattern |
|---|---|---|
| Get all (+relations) | `GET` | `/tickets?select=*,comments(*),ticket_history(*),ticket_attachments(*)&order=created_at.desc` |
| Get by user | `GET` | `/tickets?created_by=eq.X&select=...&order=...` |
| Get by assignee | `GET` | `/tickets?assigned_to=eq.X&select=...&order=...` |
| Create | `POST` | `/tickets` |
| Update status | `PATCH` | `/tickets?id=eq.X` |

**Penjelasan scope query per role:**

| Method | Dipakai Oleh | Tujuan |
|---|---|---|
| `getAllTickets()` | Helpdesk & Admin | Lihat **semua tiket** lintas user (admin view) |
| `getTicketsByUser(userId)` | User biasa | Lihat **tiket milik sendiri** saja |
| `getTicketsAssignedTo(helpdeskId)` | Helpdesk | Lihat tiket yang **sudah di-claim/di-assign** ke dirinya |

### 4.2.3 Tabel `comments`

| Operasi | HTTP Method | URL Pattern |
|---|---|---|
| Create | `POST` | `/comments` |
| (read via parent select) | - | otomatis lewat `tickets?select=...,comments(*)` |

### 4.2.4 Tabel `ticket_history`

| Operasi | HTTP Method | URL Pattern |
|---|---|---|
| Create | `POST` | `/ticket_history` |
| (read via parent) | - | otomatis |

### 4.2.5 Tabel `notifications`

| Operasi | HTTP Method | URL Pattern |
|---|---|---|
| Get all | `GET` | `/notifications?select=id,title,message,ticket_id,is_read,created_at&order=created_at.desc` |
| Add | `POST` | `/notifications` (upsert by id) |
| Mark read | `PATCH` | `/notifications?id=eq.X` body `{is_read:true}` |
| Mark all | `PATCH` | `/notifications?is_read=eq.false` body `{is_read:true}` |

### 4.2.6 Tabel `ticket_attachments`

| Operasi | HTTP Method | URL Pattern |
|---|---|---|
| Create row | `POST` | `/ticket_attachments` |
| Upload file | `POST` | `/storage/v1/object/attachments/<path>` (binary) |

## 4.3 Pola Kode — SupabaseService (Snippet)

```dart
// lib/services/supabase_service.dart
class SupabaseService {
  final _db = Supabase.instance.client;

  // ── LOGIN ──
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

  // ── BUAT TIKET ──
  Future<void> createTicket({
    required String id,
    required String title,
    required String description,
    required TicketCategory category,
    required TicketPriority priority,
    required String createdBy,
  }) async {
    // 1. INSERT row tiket
    await _db.from('tickets').insert({
      'id':          id,
      'title':       title,
      'description': description,
      'category':    category.name,
      'priority':    priority.name,
      'status':      TicketStatus.open.name,
      'created_by':  createdBy,
    });
    // 2. INSERT history entry pertama
    await _db.from('ticket_history').insert({
      'ticket_id': id,
      'status':    TicketStatus.open.name,
      'note':      'Tiket dibuat',
    });
    // 3. Notifikasi di-trigger oleh TicketProvider setelah createTicket
    //    kembali (lihat 4.4) — Service TIDAK insert notif sendiri
  }

  // ── UBAH STATUS ──
  Future<void> updateTicketStatus({
    required String ticketId,
    required TicketStatus status,
    required String note,
    String? assignedTo,
  }) async {
    final update = {
      'status':     status.name,
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (assignedTo != null) update['assigned_to'] = assignedTo;

    await _db.from('tickets').update(update).eq('id', ticketId);
    await _db.from('ticket_history').insert({
      'ticket_id': ticketId,
      'status':    status.name,
      'note':      note,
    });
    // Notif di-trigger dari TicketProvider (lihat 4.4)
  }

  // ── UPLOAD ATTACHMENT (Supabase Storage) ──
  Future<String?> uploadAttachment({
    required String ticketId,
    required Uint8List fileBytes,
    required String fileName,
  }) async {
    try {
      final path =
          '$ticketId/${DateTime.now().millisecondsSinceEpoch}_$fileName';
      await _db.storage.from('attachments').uploadBinary(path, fileBytes);
      final url = _db.storage.from('attachments').getPublicUrl(path);
      await _db.from('ticket_attachments').insert({
        'ticket_id': ticketId,
        'file_url':  url,
        'file_name': fileName,
      });
      return url;
    } catch (e) {
      return null;   // upload gagal → kembalikan null, caller cek
    }
  }
}
```

**Catatan penting:** Snippet di atas hanya menampilkan `SupabaseService`. Pemanggilan `addNotification(...)` terjadi di **`TicketProvider`** setelah method Service di atas selesai — lihat 4.4 untuk alur lengkap.

## 4.4 Trigger Notifikasi Otomatis

Di implementasi saat ini, **notifikasi di-insert oleh `TicketProvider`** (bukan dari `SupabaseService` itu sendiri) setelah operasi utama Service berhasil. Polanya:

1. `TicketProvider` panggil `_service.createTicket(...)` / `updateTicketStatus(...)` / `addComment(...)`.
2. Setelah method Service return sukses, `TicketProvider` langsung panggil `_service.addNotification(...)`.
3. Insert notifikasi dibungkus `try-catch` dengan **swallow** (lihat 4.5) — kalau notifikasi gagal, alur utama tiket tidak ikut gagal.

Snippet alur di `ticket_provider.dart`:

```dart
// lib/presentation/providers/ticket_provider.dart
Future<void> createTicket({...}) async {
  await _service.createTicket(        // ← 1. Service: insert tiket + history
    id: id, title: title, ...,
  );
  await _service.addNotification(     // ← 2. Provider: insert notif terpisah
    id: 'n-new-${id}-${uuid}',
    title: 'Tiket $id Dibuat',
    message: '...',
    ticketId: id,
  );
  await loadTickets(currentUserId);   // ← 3. reload list agar UI update
  notifyListeners();
}
```

**Contoh aksi yang memicu notifikasi:**

| Aksi | Tipe Notif | `ticketId` |
|---|---|---|
| Buat tiket baru | `'Tiket T-... Dibuat'` | tiket baru |
| Ubah status tiket | `'Status Tiket T-... Berubah'` | tiket |
| Tambah komentar | `'Komentar Baru di Tiket T-...'` | tiket |
| Assign tiket ke helpdesk | `'Tiket T-... Ditugaskan'` | tiket |
| Admin tambah user | `'Pengguna Baru Ditambahkan'` | null (sistem) |
| Admin hapus user | `'Pengguna Dihapus'` | null (sistem) |
| Admin aktif/nonaktif user | `'Pengguna Diaktifkan/Dinonaktifkan'` | null (sistem) |
| Admin ubah role | `'Role Pengguna Diubah'` | null (sistem) |

**Id notifikasi menggunakan prefix agar mudah di-filter:**
- `n-new-<uuid>` — tiket baru
- `n-sts-<uuid>` — status berubah
- `n-cmt-<uuid>` — komentar baru
- `n-asn-<uuid>` — di-assign
- `n-new-user-<uuid>` — user baru
- `n-delete-<uuid>` — user dihapus
- `n-active-<uuid>` — user aktif/nonaktif
- `n-role-<uuid>` — role berubah

**Kenapa dipisah dari Service?** Supaya logic notifikasi (prefix ID, format judul) tidak tercampur dengan logic bisnis tiket. Kalau nanti notif mau pakai push notification (FCM), cukup ganti implementasi di `addNotification`, logic Service tiket tidak perlu diubah.

## 4.5 Error Handling

Semua method di `SupabaseService` melemparkan exception yang ditangkap di level Provider/Screen:

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

## 4.6 Realtime (Future)

Saat ini tidak ada subscription realtime — user harus pull-to-refresh atau buka ulang tab. Untuk production bisa pakai Supabase Realtime:

```dart
final sub = _db
  .from('notifications')
  .stream(primaryKey: ['id'])
  .listen((rows) {
    // update UI otomatis
  });
```

Tidak diimplementasikan untuk UAS ini karena alasan kesederhanaan.

## 4.7 Kuota & Limit

| Resource | Free Tier | Penggunaan |
|---|---|---|
| Database size | 500 MB | < 1 MB |
| Storage | 1 GB | < 10 MB |
| Bandwidth | 2 GB/bulan | < 50 MB |
| Realtime connections | 200 concurrent | - |
| Edge functions | 500k/bulan | 0 |

Untuk UAS demo, **free tier lebih dari cukup**.