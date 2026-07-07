import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/ticket_provider.dart';
import '../../../data/models/ticket_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/status_badge_widget.dart';
import '../../../data/models/user_model.dart';
import '../../../services/supabase_service.dart';

class TicketDetailScreen extends StatefulWidget {
  final String ticketId;
  const TicketDetailScreen({super.key, required this.ticketId});

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _commentCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _commentCtrl.dispose();
    super.dispose();
  }

  void _showFullImage(BuildContext context, Uint8List imageBytes) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(10),
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.adaptiveText(context), width: 4),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Image.memory(imageBytes),
              ),
            ),
            Positioned(
              top: 10, right: 10,
              child: Container(
                decoration: BoxDecoration(color: AppTheme.adaptiveText(context), borderRadius: BorderRadius.circular(4)),
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final ticketProvider = Provider.of<TicketProvider>(context);
    final ticket = ticketProvider.getTicketById(widget.ticketId);

    if (ticket == null) {
      return Scaffold(
        appBar: AppBar(automaticallyImplyLeading: true),
        body: Center(
          child: Text(
            'TIKET TIDAK DITEMUKAN',
            style: GoogleFonts.spaceGrotesk(
              fontWeight: FontWeight.w900, color: AppTheme.adaptiveText(context), letterSpacing: 2,
            ),
          ),
        ),
      );
    }

    final user = auth.currentUser!;
    final isAdminOrHelpdesk = user.role.name != 'user';

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        elevation: 0,
        backgroundColor: AppTheme.adaptiveBackground(context),
        foregroundColor: AppTheme.adaptiveText(context),
        centerTitle: false,
        title: Text(
          '#${ticket.id.toUpperCase()}',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.3,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.adaptiveText(context),
          indicatorWeight: 3,
          labelStyle: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, fontSize: 12),
          unselectedLabelColor: AppTheme.adaptiveTextSecondary(context),
          labelColor: AppTheme.adaptiveText(context),
          tabs: const [Tab(text: 'DETAIL'), Tab(text: 'KOMENTAR'), Tab(text: 'RIWAYAT')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDetailTab(ticket, user, isAdminOrHelpdesk, ticketProvider),
          _buildCommentTab(ticket, user, ticketProvider),
          _buildHistoryTab(ticket),
        ],
      ),
    );
  }

  Widget _buildDetailTab(
      TicketModel ticket, UserModel user, bool isAdminOrHelpdesk, TicketProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            ticket.title,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.adaptiveText(context), letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),

          // Badges
          Wrap(
            spacing: 8,
            children: [
              StatusBadge(label: ticket.statusLabel, color: AppTheme.getStatusColor(ticket.statusLabel)),
              StatusBadge(label: ticket.priorityLabel, color: AppTheme.getPriorityColor(ticket.priorityLabel)),
              StatusBadge(label: ticket.categoryLabel, color: AppTheme.acidPurple),
            ],
          ),
          const SizedBox(height: 16),

          // Info brutal cards
          _BrutInfoRow(icon: Icons.calendar_today_rounded, label: 'DIBUAT', value: DateFormat('dd MMM yyyy, HH:mm').format(ticket.createdAt)),
          _BrutInfoRow(icon: Icons.update_rounded, label: 'DIPERBARUI', value: DateFormat('dd MMM yyyy, HH:mm').format(ticket.updatedAt)),
          if (ticket.assignedTo != null)
            FutureBuilder<UserModel?>(
              future: SupabaseService().getUserById(ticket.assignedTo!),
              builder: (_, snap) => _BrutInfoRow(
                icon: Icons.person_rounded, label: 'DITANGANI', value: snap.data?.name ?? 'Memuat...',
              ),
            ),
          const SizedBox(height: 16),

          // Deskripsi
          Text('DESKRIPSI', style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w900, color: AppTheme.adaptiveText(context), letterSpacing: 1)),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.adaptiveBackground(context),
              border: Border.all(color: AppTheme.adaptiveText(context), width: 2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              ticket.description,
              style: GoogleFonts.spaceGrotesk(fontSize: 14, color: AppTheme.adaptiveText(context)),
            ),
          ),
          const SizedBox(height: 16),

          // Lampiran
          if (ticket.attachments != null && ticket.attachments!.isNotEmpty) ...[
            Text('LAMPIRAN', style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w900, color: AppTheme.adaptiveText(context), letterSpacing: 1)),
            const SizedBox(height: 10),
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: ticket.attachments!.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _showFullImage(context, ticket.attachments![index]),
                    child: Container(
                      width: 100,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.adaptiveText(context), width: 3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: Image.memory(ticket.attachments![index], fit: BoxFit.cover),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Update Status (admin & helpdesk)
          if (isAdminOrHelpdesk) ...[
            Row(
              children: [
                Container(width: 4, height: 18, color: AppTheme.adaptiveText(context)),
                const SizedBox(width: 6),
                Text('UPDATE STATUS', style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w900, color: AppTheme.adaptiveText(context), letterSpacing: 1)),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: TicketStatus.values.map((s) {
                final isActive = ticket.status == s;
                return GestureDetector(
                  onTap: () => _showUpdateStatusDialog(s, provider, ticket.id),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isActive ? AppTheme.adaptiveText(context) : AppTheme.adaptiveBackground(context),
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(color: AppTheme.adaptiveText(context), width: isActive ? 3 : 2),
                      boxShadow: isActive ? [BoxShadow(color: AppTheme.adaptiveText(context), offset: Offset(3, 3), blurRadius: 0)] : null,
                    ),
                    child: Text(
                      _statusLabel(s),
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: isActive ? AppTheme.primary : AppTheme.adaptiveText(context),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],

          // Assign ke Helpdesk
          if (user.role == UserRole.admin && ticket.status == TicketStatus.open)
            _buildAssignSection(ticket, provider),
        ],
      ),
    );
  }

  Widget _buildAssignSection(TicketModel ticket, TicketProvider provider) {
    return FutureBuilder<List<UserModel>>(
      future: SupabaseService().getAllUsers(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Padding(padding: const EdgeInsets.only(top: 16), child: Center(child: CircularProgressIndicator(color: AppTheme.adaptiveText(context))));
        }
        final helpdeskList = snapshot.data!.where((u) => u.role == UserRole.helpdesk).toList();
        if (helpdeskList.isEmpty) {
          return const Padding(padding: EdgeInsets.only(top: 16), child: Text('Tidak ada helpdesk tersedia.', style: TextStyle(color: Colors.grey)));
        }
        String? selectedId = ticket.assignedTo;
        return StatefulBuilder(
          builder: (context, setLocalState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(width: 4, height: 18, color: AppTheme.acidRed),
                    const SizedBox(width: 6),
                    Text('ASSIGN KEPAD A', style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w900, color: AppTheme.adaptiveText(context), letterSpacing: 1)),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.adaptiveText(context), width: 3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: DropdownButtonFormField<String>(
                    // ignore: deprecated_member_use
                    value: helpdeskList.any((h) => h.id == selectedId) ? selectedId : null,
                    decoration: const InputDecoration.collapsed(hintText: 'Pilih helpdesk'),
                    dropdownColor: AppTheme.adaptiveBackground(context),
                    icon: Icon(Icons.arrow_drop_down_rounded, color: AppTheme.adaptiveText(context)),
                    style: GoogleFonts.spaceGrotesk(fontSize: 14, color: AppTheme.adaptiveText(context), fontWeight: FontWeight.w600),
                    items: helpdeskList.map((h) => DropdownMenuItem(value: h.id, child: Text(h.name))).toList(),
                    onChanged: (helpdeskId) {
                      if (helpdeskId == null) return;
                      setLocalState(() => selectedId = helpdeskId);
                      provider.assignTicket(ticket.id, helpdeskId);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Tiket di-assign ke helpdesk terpilih'),
                          backgroundColor: AppTheme.isDark(context) ? AppTheme.cardDark : AppTheme.ink,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _statusLabel(TicketStatus s) {
    switch (s) {
      case TicketStatus.open: return 'OPEN';
      case TicketStatus.inProgress: return 'IN PROGRESS';
      case TicketStatus.resolved: return 'RESOLVED';
      case TicketStatus.closed: return 'CLOSED';
    }
  }

  void _showUpdateStatusDialog(TicketStatus newStatus, TicketProvider provider, String ticketId) {
    final noteCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: AppTheme.adaptiveBackground(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4), side: BorderSide(color: AppTheme.adaptiveText(context), width: 3)),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('UPDATE KE ${_statusLabel(newStatus)}?', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, fontSize: 16, color: AppTheme.adaptiveText(context))),
              const SizedBox(height: 12),
              TextField(
                controller: noteCtrl,
                decoration: InputDecoration(
                  labelText: 'CATATAN (OPSIONAL)',
                  labelStyle: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.w700),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                ),
                maxLines: null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppTheme.adaptiveText(context), width: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                      child: Text('BATAL', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, fontSize: 13)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        provider.updateStatus(ticketId, newStatus, noteCtrl.text.isEmpty ? 'Status diperbarui' : noteCtrl.text);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Status berhasil diperbarui'), backgroundColor: AppTheme.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4)))),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.isDark(context) ? AppTheme.cardDark : AppTheme.ink,
                        foregroundColor: AppTheme.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                      child: Text('UPDATE', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, fontSize: 13)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommentTab(TicketModel ticket, UserModel user, TicketProvider provider) {
    return Column(
      children: [
        Expanded(
          child: ticket.comments.isEmpty
              ? Center(child: Text('KOSONG', style: TextStyle(fontFamily: 'SpaceGrotesk', fontWeight: FontWeight.w900, color: AppTheme.adaptiveText(context), letterSpacing: 4)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: ticket.comments.length,
                  itemBuilder: (_, i) {
                    final c = ticket.comments[i];
                    return _CommentCard(comment: c, isMe: c.userId == user.id);
                  },
                ),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.adaptiveSurface(context),
            border: Border.all(color: AppTheme.adaptiveText(context), width: 2),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentCtrl,
                  decoration: InputDecoration(
                    hintText: 'Tulis komentar...',
                    hintStyle: GoogleFonts.spaceGrotesk(color: AppTheme.adaptiveTextSecondary(context)),
                    filled: true,
                    fillColor: AppTheme.adaptiveBackground(context),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  maxLines: null,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.adaptiveText(context),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: IconButton(
                  icon: Icon(Icons.send_rounded, color: AppTheme.primary, size: 20),
                  onPressed: () {
                    if (_commentCtrl.text.trim().isNotEmpty) {
                      provider.addComment(ticket.id, user.id, user.name, _commentCtrl.text.trim());
                      _commentCtrl.clear();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryTab(TicketModel ticket) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: ticket.history.length,
      itemBuilder: (_, i) {
        final h = ticket.history[ticket.history.length - 1 - i];
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 14, height: 14,
                  decoration: BoxDecoration(
                    color: AppTheme.getStatusColor(TicketModel(id: '', title: '', description: '', category: TicketCategory.other, priority: TicketPriority.low, status: h.status, createdBy: '', createdAt: DateTime.now(), updatedAt: DateTime.now(), comments: [], history: []).statusLabel),
                    border: Border.all(color: AppTheme.adaptiveText(context), width: 2),
                    shape: BoxShape.circle,
                  ),
                ),
                if (i < ticket.history.length - 1) Container(width: 2, height: 50, color: AppTheme.ink.withOpacity(0.2)),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppTheme.adaptiveBackground(context),
                  border: Border.all(color: AppTheme.adaptiveText(context), width: 1.5),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(h.note, style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.adaptiveText(context))),
                    const SizedBox(height: 4),
                    Text(DateFormat('dd MMM yyyy, HH:mm').format(h.changedAt), style: GoogleFonts.spaceGrotesk(fontSize: 11, color: AppTheme.adaptiveTextSecondary(context), fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _BrutInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _BrutInfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.adaptiveBackground(context),
        border: Border.all(color: AppTheme.adaptiveText(context), width: 2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.adaptiveText(context)),
          const SizedBox(width: 10),
          Text('$label: ', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, fontSize: 10, color: AppTheme.adaptiveText(context), letterSpacing: 1)),
          Expanded(child: Text(value, style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.adaptiveText(context)))),
        ],
      ),
    );
  }
}

class _CommentCard extends StatelessWidget {
  final dynamic comment;
  final bool isMe;
  const _CommentCard({required this.comment, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        decoration: BoxDecoration(
          color: isMe ? (AppTheme.isDark(context) ? AppTheme.cardDark : AppTheme.ink) : AppTheme.adaptiveBackground(context),
          border: Border.all(color: AppTheme.adaptiveText(context), width: isMe ? 0 : 2),
          borderRadius: BorderRadius.circular(4),
          boxShadow: [BoxShadow(color: AppTheme.adaptiveText(context), offset: const Offset(3, 3), blurRadius: 0)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              comment.userName,
              style: GoogleFonts.spaceGrotesk(
                fontWeight: FontWeight.w900,
                fontSize: 11,
                color: isMe ? AppTheme.primary : AppTheme.adaptiveText(context),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(comment.content, style: GoogleFonts.spaceGrotesk(fontSize: 13, color: isMe ? AppTheme.primary : AppTheme.adaptiveText(context))),
            const SizedBox(height: 4),
            Text(DateFormat('HH:mm').format(comment.createdAt), style: GoogleFonts.spaceGrotesk(fontSize: 10, color: isMe ? AppTheme.primary : AppTheme.adaptiveTextSecondary(context), fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
