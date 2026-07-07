class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String? ticketId; // nullable agar tidak error parse kalau null
  bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    this.ticketId,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    // Parsing super-defensif agar satu baris rusak tidak menggagalkan seluruh list
    try {
      return NotificationModel(
        id:        (json['id'] ?? '').toString(),
        title:     (json['title'] ?? '(Tanpa judul)').toString(),
        message:   (json['message'] ?? '').toString(),
        ticketId:  json['ticket_id']?.toString(),
        isRead:    json['is_read'] == true,
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
            : DateTime.now(),
      );
    } catch (e) {
      // ignore: avoid_print
      print('[NOTIF] parse error: $e | json=$json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => {
    'id':         id,
    'title':      title,
    'message':    message,
    'ticket_id':  ticketId,
    'is_read':    isRead,
    'created_at': createdAt.toIso8601String(),
  };
}