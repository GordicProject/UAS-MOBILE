import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/ticket_model.dart';
import '../../services/supabase_service.dart';   // ← import service baru

class TicketProvider extends ChangeNotifier {
  final _service = SupabaseService();
  final _uuid = const Uuid();

  List<TicketModel> _tickets       = [];
  String _filterStatus             = 'all';
  String _filterPriority           = 'all';
  bool _isLoading                  = false;

  List<TicketModel> get tickets    => _tickets;
  String get filterStatus          => _filterStatus;
  String get filterPriority        => _filterPriority;
  bool get isLoading               => _isLoading;

  String _statusLabel(TicketStatus s) {
    switch (s) {
      case TicketStatus.open:       return 'Open';
      case TicketStatus.inProgress: return 'In Progress';
      case TicketStatus.resolved:   return 'Resolved';
      case TicketStatus.closed:     return 'Closed';
    }
  }

  // ── LOAD ──────────────────────────────────────────────
  Future<void> loadAllTickets() async {
    _isLoading = true;
    notifyListeners();
    try {
      _tickets = await _service.getAllTickets();
    } catch (e) {
      debugPrint('loadAllTickets error: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadTicketsForUser(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _tickets = await _service.getTicketsByUser(userId);
    } catch (e) {
      debugPrint('loadTicketsForUser error: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  // ── FILTER ────────────────────────────────────────────
  List<TicketModel> getTicketsForUser(String userId) =>
      _tickets.where((t) => t.createdBy == userId).toList();

  List<TicketModel> get filteredTickets {
    return _tickets.where((t) {
      final statusMatch   = _filterStatus == 'all' ||
          t.statusLabel.toLowerCase() == _filterStatus.toLowerCase();
      final priorityMatch = _filterPriority == 'all' ||
          t.priorityLabel.toLowerCase() == _filterPriority.toLowerCase();
      return statusMatch && priorityMatch;
    }).toList();
  }

  TicketModel? getTicketById(String id) {
    try   { return _tickets.firstWhere((t) => t.id == id); }
    catch (_) { return null; }
  }

  void setFilterStatus(String s)   { _filterStatus = s;   notifyListeners(); }
  void setFilterPriority(String p) { _filterPriority = p; notifyListeners(); }

  // ── CRUD ──────────────────────────────────────────────
  Future<void> createTicket({
    required String title,
    required String description,
    required TicketCategory category,
    required TicketPriority priority,
    required String createdBy,
    List<Uint8List>? attachments,
  }) async {
    final newId = 'T-${DateTime.now().millisecondsSinceEpoch}';

    // 1. Simpan tiket dulu ke database
    await _service.createTicket(
      id:          newId,
      title:       title,
      description: description,
      category:    category,
      priority:    priority,
      createdBy:   createdBy,
    );
    debugPrint('✅ tiket berhasil disimpan: $newId');

    // 2. Upload attachment jika ada
    if (attachments != null) {
      for (int i = 0; i < attachments.length; i++) {
        await _service.uploadAttachment(
          ticketId:  newId,
          fileBytes: attachments[i],
          fileName:  'attachment_$i.jpg',
        );
      }
      debugPrint('✅ attachment ter-upload ($attachments.length file)');
    }

    // 3. Buat notifikasi — TANPA cek user lain, langsung insert 1 notif universal
    final notifId = 'n-new-${_uuid.v4()}';
    await _service.addNotification(
      id:       notifId,
      title:    'Tiket $newId Dibuat',
      message:  'Tiket baru "$title" (kategori: ${category.name}, prioritas: ${priority.name}) telah dibuat dan menunggu penanganan.',
      ticketId: newId,
    );
    debugPrint('✅ notifikasi berhasil ditambahkan: $notifId');

    // 4. Reload tiket user yang baru login
    await loadTicketsForUser(createdBy);
    debugPrint('✅ loadTicketsForUser selesai');
  }

  Future<void> updateStatus(
      String ticketId, TicketStatus newStatus, String note) async {
    await _service.updateTicketStatus(
        ticketId: ticketId, status: newStatus, note: note);

    final notifId = 'n-sts-${_uuid.v4()}';
    await _service.addNotification(
      id:       notifId,
      title:    'Status Tiket $ticketId Berubah',
      message:  'Tiket diperbarui menjadi ${_statusLabel(newStatus)}. $note',
      ticketId: ticketId,
    );

    final idx = _tickets.indexWhere((t) => t.id == ticketId);
    if (idx != -1) {
      _tickets[idx].status    = newStatus;
      _tickets[idx].updatedAt = DateTime.now();
      _tickets[idx].history.add(
          HistoryModel(status: newStatus, changedAt: DateTime.now(), note: note));
      notifyListeners();
    }
  }

  Future<void> addComment(String ticketId, String userId,
      String userName, String content) async {
    final id = 'c${DateTime.now().millisecondsSinceEpoch}';
    await _service.addComment(
      id: id, ticketId: ticketId,
      userId: userId, userName: userName, content: content,
    );

    final notifId = 'n-cmt-${_uuid.v4()}';
    await _service.addNotification(
      id:       notifId,
      title:    'Komentar Baru di Tiket $ticketId',
      message:  '$userName menambahkan komentar: "$content"',
      ticketId: ticketId,
    );

    final idx = _tickets.indexWhere((t) => t.id == ticketId);
    if (idx != -1) {
      _tickets[idx].comments.add(CommentModel(
        id: id, ticketId: ticketId, userId: userId,
        userName: userName, content: content, createdAt: DateTime.now(),
      ));
      _tickets[idx].updatedAt = DateTime.now();
      notifyListeners();
    }
  }

  Future<void> assignTicket(String ticketId, String helpdeskId) async {
    await _service.updateTicketStatus(
      ticketId:   ticketId,
      status:     TicketStatus.inProgress,
      note:       'Tiket di-assign ke helpdesk',
      assignedTo: helpdeskId,
    );

    final notifId = 'n-asn-${_uuid.v4()}';
    await _service.addNotification(
      id:       notifId,
      title:    'Tiket $ticketId Ditugaskan',
      message:  'Tiket telah di-assign ke helpdesk dan sedang diproses.',
      ticketId: ticketId,
    );

    final idx = _tickets.indexWhere((t) => t.id == ticketId);
    if (idx != -1) {
      _tickets[idx].assignedTo = helpdeskId;
      _tickets[idx].updatedAt  = DateTime.now();
      notifyListeners();
    }
  }

  Future<void> loadTicketsForHelpdesk(String helpdeskId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _tickets = await _service.getTicketsAssignedTo(helpdeskId);
    } catch (e) {
      debugPrint('loadTicketsForHelpdesk error: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  // ── STATISTIK ─────────────────────────────────────────
  int get totalTickets      => _tickets.length;
  int get openTickets       => _tickets.where((t) => t.status == TicketStatus.open).length;
  int get inProgressTickets => _tickets.where((t) => t.status == TicketStatus.inProgress).length;
  int get resolvedTickets   => _tickets.where((t) => t.status == TicketStatus.resolved).length;
  int get closedTickets     => _tickets.where((t) => t.status == TicketStatus.closed).length;
}