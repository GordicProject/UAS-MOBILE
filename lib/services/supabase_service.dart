import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/ticket_model.dart';
import '../data/models/user_model.dart';
import '../data/models/notification_model.dart';

class SupabaseService {
  final _db = Supabase.instance.client;

  // ── AUTH / USERS ───────────────────────────────────────────────────────

  Future<UserModel?> login(String email, String password) async {
    final res = await _db
        .from('users')
        .select('id, name, email, password, role, avatar_url, created_at, is_active')
        .eq('email', email)
        .eq('password', password)
        .maybeSingle();
    if (res == null) return null;
    final user = UserModel.fromJson(res);
    // Tolak akun yang dinonaktifkan
    if (user.isActive == false) return null;
    return user;
  }

  Future<List<UserModel>> getAllUsers() async {
    // Eksplisit select semua kolom termasuk is_active.
    final res = await _db.from('users').select(
      'id, name, email, password, role, avatar_url, created_at, is_active',
    );
    return (res as List).map((e) => UserModel.fromJson(e)).toList();
  }

  /// Ambil satu user berdasarkan ID — dipakai untuk menampilkan nama
  /// helpdesk yang di-assign di ticket_detail_screen.dart
  Future<UserModel?> getUserById(String userId) async {
    final res = await _db
        .from('users')
        .select('id, name, email, password, role, avatar_url, created_at, is_active')
        .eq('id', userId)
        .maybeSingle();
    if (res == null) return null;
    return UserModel.fromJson(res);
  }

  Future<void> createUser(UserModel user) async {
    await _db.from('users').insert({
      'id':         user.id,
      'name':       user.name,
      'email':      user.email,
      'password':   user.password,
      'role':       user.role.name,
      'created_at': user.createdAt.toIso8601String(),
    });
  }

  /// Nonaktifkan pengguna — set is_active = false.
  /// Hapus user dari database (hard delete).
  /// Karena ada FK dari tabel lain ke users(id), pastikan:
  ///   1. ON DELETE SET NULL / CASCADE di kolom created_by & assigned_to di tabel tickets
  ///   2. ON DELETE CASCADE di tabel comments.user_id & ticket_history
  ///   3. Baris user tidak memiliki ticket/comment yang masih dirujuk
  Future<void> deleteUser(String userId) async {
    await _db.from('users').delete().eq('id', userId);
  }

  /// Nonaktifkan user (soft delete) — set is_active = false
  Future<void> deactivateUser(String userId) async {
    // ignore: avoid_print
    print('[SVC] deactivateUser id=$userId');
    final res = await _db
        .from('users')
        .update({'is_active': false})
        .eq('id', userId)
        .select();
    // ignore: avoid_print
    print('[SVC] deactivateUser response=$res');
  }

  /// Aktifkan kembali user — set is_active = true
  Future<void> activateUser(String userId) async {
    // ignore: avoid_print
    print('[SVC] activateUser id=$userId');
    final res = await _db
        .from('users')
        .update({'is_active': true})
        .eq('id', userId)
        .select();
    // ignore: avoid_print
    print('[SVC] activateUser response=$res');
  }

  /// Update role user (admin only) — ubah antara user/helpdesk/admin
  Future<void> updateUserRole(String userId, UserRole newRole) async {
    await _db
        .from('users')
        .update({'role': newRole.name})
        .eq('id', userId);
  }

  // ── TICKETS ────────────────────────────────────────────────────────────

  /// Ambil semua tiket beserta relasi (untuk admin)
  Future<List<TicketModel>> getAllTickets() async {
    final res = await _db
        .from('tickets')
        .select('*, comments(*), ticket_history(*), ticket_attachments(*)')
        .order('created_at', ascending: false);
    return (res as List).map((e) => TicketModel.fromJson(e)).toList();
  }

  /// Ambil tiket milik user tertentu
  Future<List<TicketModel>> getTicketsByUser(String userId) async {
    final res = await _db
        .from('tickets')
        .select('*, comments(*), ticket_history(*), ticket_attachments(*)')
        .eq('created_by', userId)
        .order('created_at', ascending: false);
    return (res as List).map((e) => TicketModel.fromJson(e)).toList();
  }

  /// Ambil tiket yang di-assign ke helpdesk tertentu
  Future<List<TicketModel>> getTicketsAssignedTo(String userId) async {
    final res = await _db
        .from('tickets')
        .select('*, comments(*), ticket_history(*), ticket_attachments(*)')
        .eq('assigned_to', userId)
        .order('created_at', ascending: false);
    return (res as List).map((e) => TicketModel.fromJson(e)).toList();
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
  }

  // ── COMMENTS ───────────────────────────────────────────────────────────

  Future<void> addComment({
    required String id,
    required String ticketId,
    required String userId,
    required String userName,
    required String content,
  }) async {
    await _db.from('comments').insert({
      'id':        id,
      'ticket_id': ticketId,
      'user_id':   userId,
      'user_name': userName,
      'content':   content,
    });

    await _db.from('tickets').update({
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', ticketId);
  }

  // ── NOTIFICATIONS ──────────────────────────────────────────────────────

  Future<List<NotificationModel>> getNotifications() async {
    final res = await _db
        .from('notifications')
        .select('id, title, message, ticket_id, is_read, created_at')
        .order('created_at', ascending: false);
    final list = res as List;
    // ignore: avoid_print
    print('[SVC] getNotifications raw count = ${list.length}');
    final out = <NotificationModel>[];
    for (final row in list) {
      try {
        out.add(NotificationModel.fromJson(row));
      } catch (e) {
        // ignore: avoid_print
        print('[SVC] skip broken notification: $e | row=$row');
      }
    }
    return out;
  }

  Future<void> addNotification({
    required String id,
    required String title,
    required String message,
    String? ticketId,
  }) async {
    // Kalau ticketId kosong / 'system' / null → jangan kirim kolom ticket_id
    // supaya tidak kena foreign key constraint ke tabel tickets
    final data = <String, dynamic>{
      'id':      id,
      'title':   title,
      'message': message,
      'is_read': false,
    };
    if (ticketId != null && ticketId.isNotEmpty && ticketId != 'system') {
      data['ticket_id'] = ticketId;
    }
    // Pakai upsert + ignoreDuplicates supaya kalau id bentrok, tidak error 409
    await _db.from('notifications').upsert(data, ignoreDuplicates: true);
  }

  Future<void> markNotificationRead(String id) async {
    await _db.from('notifications')
        .update({'is_read': true}).eq('id', id);
  }

  Future<void> markAllNotificationsRead() async {
    await _db.from('notifications')
        .update({'is_read': true}).eq('is_read', false);
  }

  // ── ATTACHMENTS ────────────────────────────────────────────────────────

  Future<String?> uploadAttachment({
    required String ticketId,
    required Uint8List fileBytes,
    required String fileName,
  }) async {
    try {
      final path =
          '$ticketId/${DateTime.now().millisecondsSinceEpoch}_$fileName';
      await _db.storage.from('attachments').uploadBinary(path, fileBytes);
      final url =
      _db.storage.from('attachments').getPublicUrl(path);

      await _db.from('ticket_attachments').insert({
        'ticket_id': ticketId,
        'file_url':  url,
        'file_name': fileName,
      });
      return url;
    } catch (e) {
      return null;
    }
  }
}