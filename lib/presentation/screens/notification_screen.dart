import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../data/models/notification_model.dart';
import '../../services/supabase_service.dart';
import '../../core/theme/app_theme.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with WidgetsBindingObserver {
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadNotifications();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadNotifications();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    try {
      final data = await SupabaseService().getNotifications();
      // ignore: avoid_print
      print('[NOTIF] loaded ${data.length} notifications');
      setState(() {
        _notifications = data;
        _isLoading = false;
      });
    } catch (e) {
      // ignore: avoid_print
      print('[NOTIF] FAILED: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Gagal memuat notifikasi: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => !n.isRead).length;

    return Scaffold(
      backgroundColor: AppTheme.adaptiveBackground(context),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            border: Border.all(color: AppTheme.adaptiveText(context), width: 3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: AppTheme.adaptiveText(context),
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'NOTIFIKASI',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.adaptiveText(context),
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  if (unreadCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        border: Border.all(color: AppTheme.adaptiveText(context), width: 2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Text(
                        '$unreadCount BELUM DIBACA',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.adaptiveText(context),
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── Body ───────────────────────────────────────────────────
            Expanded(
              child: RefreshIndicator(
                color: AppTheme.adaptiveText(context),
                backgroundColor: AppTheme.primary,
                onRefresh: _loadNotifications,
                child: _isLoading
                    ? Center(child: CircularProgressIndicator(color: AppTheme.adaptiveText(context)))
                    : _notifications.isEmpty
                        ? ListView(
                            // ListView (bukan Center) supaya RefreshIndicator tetap bisa swipe-down
                            children: [
                              SizedBox(
                                height: 400,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 64,
                                        height: 64,
                                        decoration: BoxDecoration(
                                          border: Border.all(color: AppTheme.adaptiveText(context), width: 3),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Icon(
                                          Icons.mail_outline_rounded,
                                          color: AppTheme.adaptiveTextSecondary(context),
                                          size: 32,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'KOSONG',
                                        style: GoogleFonts.spaceGrotesk(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w900,
                                          color: AppTheme.adaptiveText(context),
                                          letterSpacing: 3,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Belum ada notifikasi',
                                        style: GoogleFonts.spaceGrotesk(
                                          fontSize: 12,
                                          color: AppTheme.adaptiveTextSecondary(context),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(20),
                            itemCount: _notifications.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (_, i) => _NotificationCard(item: _notifications[i]),
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Widget terpisah untuk card notifikasi ─────────────────────────────────
class _NotificationCard extends StatelessWidget {
  final NotificationModel item;
  const _NotificationCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        item.isRead = true;
        if (item.ticketId != null && item.ticketId!.isNotEmpty) {
          context.push('/tickets/${item.ticketId}');
        }
      },
      child: AppTheme.brutalContainer(
        context: context,
        backgroundColor: item.isRead ? AppTheme.adaptiveSurface(context) : AppTheme.primary,
        borderColor: AppTheme.adaptiveText(context),
        borderW: 3,
        padding: const EdgeInsets.all(14),
        shadows: [
          BoxShadow(
            color: AppTheme.adaptiveText(context),
            offset: const Offset(4, 4),
            blurRadius: 0,
          ),
        ],
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.adaptiveText(context),
                border: Border.all(color: AppTheme.adaptiveText(context), width: 2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                item.ticketId == null || item.ticketId!.isEmpty
                    ? Icons.admin_panel_settings_rounded
                    : Icons.confirmation_number_rounded,
                color: AppTheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      fontWeight: item.isRead ? FontWeight.w600 : FontWeight.w900,
                      color: AppTheme.adaptiveText(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.message,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      color: AppTheme.adaptiveTextSecondary(context),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('dd MMM, HH:mm').format(item.createdAt),
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 10,
                      color: AppTheme.adaptiveTextSecondary(context),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
            if (!item.isRead)
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: AppTheme.acidRed,
                  border: Border.all(color: AppTheme.adaptiveText(context), width: 1.5),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}