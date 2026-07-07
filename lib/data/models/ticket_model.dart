import 'dart:typed_data';

enum TicketStatus   { open, inProgress, resolved, closed }
enum TicketPriority { low, medium, high }
enum TicketCategory { hardware, software, network, other }

class CommentModel {
  final String id;
  final String ticketId;
  final String userId;
  final String userName;
  String content;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.ticketId,
    required this.userId,
    required this.userName,
    required this.content,
    required this.createdAt,
  });

  // ← TAMBAHKAN INI
  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id:        json['id'],
      ticketId:  json['ticket_id'],
      userId:    json['user_id'],
      userName:  json['user_name'],
      content:   json['content'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id':         id,
    'ticket_id':  ticketId,
    'user_id':    userId,
    'user_name':  userName,
    'content':    content,
    'created_at': createdAt.toIso8601String(),
  };
}

class HistoryModel {
  final TicketStatus status;
  final DateTime changedAt;
  final String note;

  HistoryModel({
    required this.status,
    required this.changedAt,
    required this.note,
  });

  // ← TAMBAHKAN INI
  factory HistoryModel.fromJson(Map<String, dynamic> json) {
    return HistoryModel(
      status:    TicketStatus.values.firstWhere((e) => e.name == json['status']),
      changedAt: DateTime.parse(json['changed_at']),
      note:      json['note'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'status':     status.name,
    'changed_at': changedAt.toIso8601String(),
    'note':       note,
  };
}

// ← MODEL BARU untuk attachment dari Supabase Storage
class AttachmentModel {
  final String id;
  final String ticketId;
  final String fileUrl;
  final String? fileName;
  final DateTime createdAt;

  AttachmentModel({
    required this.id,
    required this.ticketId,
    required this.fileUrl,
    this.fileName,
    required this.createdAt,
  });

  factory AttachmentModel.fromJson(Map<String, dynamic> json) {
    return AttachmentModel(
      id:        json['id'],
      ticketId:  json['ticket_id'],
      fileUrl:   json['file_url'],
      fileName:  json['file_name'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class TicketModel {
  final String id;
  String title;
  String description;
  TicketCategory category;
  TicketPriority priority;
  TicketStatus status;
  final String createdBy;
  String? assignedTo;
  final DateTime createdAt;
  DateTime updatedAt;
  List<CommentModel> comments;
  List<HistoryModel> history;
  List<AttachmentModel> attachmentFiles; // ← dari Supabase Storage (URL)
  final List<Uint8List>? attachments;    // ← tetap untuk kompatibilitas lama

  TicketModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.status,
    required this.createdBy,
    this.assignedTo,
    required this.createdAt,
    required this.updatedAt,
    required this.comments,
    required this.history,
    this.attachmentFiles = const [],
    this.attachments,
  });

  // ← TAMBAHKAN INI
  factory TicketModel.fromJson(Map<String, dynamic> json) {
    final commentsList = (json['comments'] as List<dynamic>? ?? [])
        .map((c) => CommentModel.fromJson(c))
        .toList();

    final historyList = (json['ticket_history'] as List<dynamic>? ?? [])
        .map((h) => HistoryModel.fromJson(h))
        .toList()
      ..sort((a, b) => a.changedAt.compareTo(b.changedAt));

    final attachList = (json['ticket_attachments'] as List<dynamic>? ?? [])
        .map((a) => AttachmentModel.fromJson(a))
        .toList();

    return TicketModel(
      id:              json['id'],
      title:           json['title'],
      description:     json['description'] ?? '',
      category:        TicketCategory.values.firstWhere((e) => e.name == json['category']),
      priority:        TicketPriority.values.firstWhere((e) => e.name == json['priority']),
      status:          TicketStatus.values.firstWhere((e) => e.name == json['status']),
      createdBy:       json['created_by'],
      assignedTo:      json['assigned_to'],
      createdAt:       DateTime.parse(json['created_at']),
      updatedAt:       DateTime.parse(json['updated_at']),
      comments:        commentsList,
      history:         historyList,
      attachmentFiles: attachList,
    );
  }

  Map<String, dynamic> toJson() => {
    'id':          id,
    'title':       title,
    'description': description,
    'category':    category.name,
    'priority':    priority.name,
    'status':      status.name,
    'created_by':  createdBy,
    'assigned_to': assignedTo,
    'updated_at':  DateTime.now().toIso8601String(),
  };

  String get statusLabel {
    switch (status) {
      case TicketStatus.open:       return 'Open';
      case TicketStatus.inProgress: return 'In Progress';
      case TicketStatus.resolved:   return 'Resolved';
      case TicketStatus.closed:     return 'Closed';
    }
  }

  String get priorityLabel {
    switch (priority) {
      case TicketPriority.low:    return 'Low';
      case TicketPriority.medium: return 'Medium';
      case TicketPriority.high:   return 'High';
    }
  }

  String get categoryLabel {
    switch (category) {
      case TicketCategory.hardware: return 'Hardware';
      case TicketCategory.software: return 'Software';
      case TicketCategory.network:  return 'Network';
      case TicketCategory.other:    return 'Other';
    }
  }
}