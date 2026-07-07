import 'dart:convert';
import 'dart:typed_data';
import '../models/ticket_model.dart';
import '../models/user_model.dart';
import '../models/notification_model.dart';

class DummyData {
  // ─── STRING BASE64 UNTUK GAMBAR DUMMY ──────────────────
  // Base64 untuk icon kotak merah kecil (Error)
  static const String _iconError =
      'iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAB3RJTUUH3goODiYSX2H6HwAAAB1pVFh0Q29tbWVudAAAAAAAQ3JlYXRlZCB3aXRoIEdJTVBkLmUHAAAAQUlEQVQ4y2P8z8Dwn4EIwAilWQxgw2QAowZgAA1g1AAGMIwGgAEEA8AARg3AAIYMwACGDMAAhgwYtYAMYNTACAAAwYgP+QWcM9sAAAAASUVORK5CYII=';

  // Base64 untuk icon kotak biru kecil (Info/Software)
  static const String _iconInfo =
      'iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAB3RJTUUH3goODiYOXf3qVQAAAB1pVFh0Q29tbWVudAAAAAAAQ3JlYXRlZCB3aXRoIEdJTVBkLmUHAAAAQUlEQVQ4y2NkYPj/n4EIwAilWQxgw2QAowZgAA1g1AAGMIwGgAEEA8AARg3AAIYMwACGDMAAhgwYtYAMYNTACAAA+iYP+bL/WCAAAAAASUVORK5CYII=';

  // Helper untuk mengubah base64 jadi Uint8List
  static Uint8List _getDummyImage(String base64String) {
    return base64Decode(base64String);
  }

  // ─── USERS ───────────────────────────────────────────────
  static final List<UserModel> users = [
    UserModel(
      id: 'u1',
      name: 'Azzam',
      email: 'azzam@example.com',
      password: '123',
      role: UserRole.user,
      avatarUrl: null,
      createdAt: DateTime(2024, 1, 10),
    ),
    UserModel(
      id: 'u2',
      name: 'Abdullah',
      email: 'abdullah@example.com',
      password: '123',
      role: UserRole.helpdesk,
      avatarUrl: null,
      createdAt: DateTime(2024, 1, 5),
    ),
    UserModel(
      id: 'u3',
      name: 'Admin Sistem',
      email: 'admin@example.com',
      password: '123',
      role: UserRole.admin,
      avatarUrl: null,
      createdAt: DateTime(2024, 1, 1),
    ),
  ];

  // ─── TICKETS ─────────────────────────────────────────────
  static List<TicketModel> tickets = [
    TicketModel(
      id: 'T-001',
      title: 'Komputer tidak bisa menyala',
      description: 'Laptop saya tiba-tiba mati dan tidak bisa dinyalakan kembali sejak kemarin pagi.',
      category: TicketCategory.hardware,
      priority: TicketPriority.high,
      status: TicketStatus.inProgress,
      createdBy: 'u1',
      assignedTo: 'u2',
      createdAt: DateTime(2025, 6, 1, 9, 0),
      updatedAt: DateTime(2025, 6, 2, 10, 30),
      attachments: [
        _getDummyImage(_iconError), // Gambar Error Merah
      ],
      comments: [
        CommentModel(
          id: 'c1',
          ticketId: 'T-001',
          userId: 'u2',
          userName: 'Abdullah',
          content: 'Sudah dicek, kemungkinan masalah di baterai. Akan segera ditangani.',
          createdAt: DateTime(2025, 6, 2, 10, 30),
        ),
      ],
      history: [
        HistoryModel(status: TicketStatus.open, changedAt: DateTime(2025, 6, 1, 9, 0), note: 'Tiket dibuat'),
        HistoryModel(status: TicketStatus.inProgress, changedAt: DateTime(2025, 6, 2, 10, 30), note: 'Sedang ditangani oleh Siti Rahayu'),
      ],
    ),
    TicketModel(
      id: 'T-002',
      title: 'Tidak bisa akses email kantor',
      description: 'Saya tidak bisa login ke email kantor sejak ganti password kemarin.',
      category: TicketCategory.software,
      priority: TicketPriority.medium,
      status: TicketStatus.open,
      createdBy: 'u1',
      assignedTo: null,
      createdAt: DateTime(2025, 6, 3, 8, 0),
      updatedAt: DateTime(2025, 6, 3, 8, 0),
      attachments: [
        _getDummyImage(_iconInfo), // Gambar Info Biru
      ],
      comments: [],
      history: [
        HistoryModel(status: TicketStatus.open, changedAt: DateTime(2025, 6, 3, 8, 0), note: 'Tiket dibuat'),
      ],
    ),
    TicketModel(
      id: 'T-003',
      title: 'Printer lantai 2 error',
      description: 'Printer di ruang meeting lantai 2 menampilkan error "Paper Jam" padahal tidak ada kertas yang nyangkut.',
      category: TicketCategory.hardware,
      priority: TicketPriority.low,
      status: TicketStatus.resolved,
      createdBy: 'u1',
      assignedTo: 'u2',
      createdAt: DateTime(2025, 5, 28, 14, 0),
      updatedAt: DateTime(2025, 5, 29, 16, 0),
      attachments: [
        _getDummyImage(_iconError), // Gambar Error Merah
      ],
      comments: [
        CommentModel(
          id: 'c2',
          ticketId: 'T-003',
          userId: 'u2',
          userName: 'Abdullah',
          content: 'Sudah diperbaiki. Ada sensor yang kotor, sudah dibersihkan.',
          createdAt: DateTime(2025, 5, 29, 16, 0),
        ),
      ],
      history: [
        HistoryModel(status: TicketStatus.open, changedAt: DateTime(2025, 5, 28, 14, 0), note: 'Tiket dibuat'),
        HistoryModel(status: TicketStatus.inProgress, changedAt: DateTime(2025, 5, 29, 9, 0), note: 'Mulai ditangani'),
        HistoryModel(status: TicketStatus.resolved, changedAt: DateTime(2025, 5, 29, 16, 0), note: 'Masalah teratasi'),
      ],
    ),
    TicketModel(
      id: 'T-004',
      title: 'Koneksi internet lambat di ruang server',
      description: 'Internet di ruang server sangat lambat sejak 3 hari lalu, menghambat pekerjaan.',
      category: TicketCategory.network,
      priority: TicketPriority.high,
      status: TicketStatus.open,
      createdBy: 'u1',
      assignedTo: null,
      createdAt: DateTime(2025, 6, 4, 7, 30),
      updatedAt: DateTime(2025, 6, 4, 7, 30),
      attachments: [
        _getDummyImage(_iconError), // Gambar Error Merah
      ],
      comments: [],
      history: [
        HistoryModel(status: TicketStatus.open, changedAt: DateTime(2025, 6, 4, 7, 30), note: 'Tiket dibuat'),
      ],
    ),
    TicketModel(
      id: 'T-005',
      title: 'Request install software Figma',
      description: 'Mohon diinstallkan Figma di laptop saya untuk keperluan desain UI project baru.',
      category: TicketCategory.software,
      priority: TicketPriority.low,
      status: TicketStatus.closed,
      createdBy: 'u1',
      assignedTo: 'u2',
      createdAt: DateTime(2025, 5, 20, 10, 0),
      updatedAt: DateTime(2025, 5, 21, 11, 0),
      attachments: [
        _getDummyImage(_iconInfo), // Gambar Info Biru
      ],
      comments: [
        CommentModel(
          id: 'c3',
          ticketId: 'T-005',
          userId: 'u2',
          userName: 'Abdullah',
          content: 'Figma sudah diinstall. Silakan dicek.',
          createdAt: DateTime(2025, 5, 21, 11, 0),
        ),
      ],
      history: [
        HistoryModel(status: TicketStatus.open, changedAt: DateTime(2025, 5, 20, 10, 0), note: 'Tiket dibuat'),
        HistoryModel(status: TicketStatus.resolved, changedAt: DateTime(2025, 5, 21, 11, 0), note: 'Software terinstall'),
        HistoryModel(status: TicketStatus.closed, changedAt: DateTime(2025, 5, 21, 11, 30), note: 'Tiket ditutup'),
      ],
    ),
  ];

  // ─── NOTIFICATIONS ───────────────────────────────────────
  static final List<NotificationModel> notifications = [
    NotificationModel(
      id: 'n1',
      title: 'Tiket T-001 Diperbarui',
      message: 'Status tiket "Komputer tidak bisa menyala" berubah menjadi In Progress.',
      ticketId: 'T-001',
      isRead: false,
      createdAt: DateTime(2025, 6, 2, 10, 30),
    ),
    NotificationModel(
      id: 'n2',
      title: 'Komentar Baru di T-001',
      message: 'Abdullah menambahkan komentar pada tiket Anda.',
      ticketId: 'T-001',
      isRead: false,
      createdAt: DateTime(2025, 6, 2, 10, 32),
    ),
    NotificationModel(
      id: 'n3',
      title: 'Tiket T-003 Selesai',
      message: 'Tiket "Printer lantai 2 error" telah diselesaikan.',
      ticketId: 'T-003',
      isRead: true,
      createdAt: DateTime(2025, 5, 29, 16, 0),
    ),
    NotificationModel(
      id: 'n4',
      title: 'Tiket T-005 Ditutup',
      message: 'Tiket "Request install software Figma" telah ditutup.',
      ticketId: 'T-005',
      isRead: true,
      createdAt: DateTime(2025, 5, 21, 11, 30),
    ),
  ];
}