import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../providers/ticket_provider.dart';
import '../../../data/models/user_model.dart';
import '../../widgets/ticket_card_widget.dart';
import '../../widgets/empty_widget.dart';
import '../../../core/theme/app_theme.dart';

class TicketListScreen extends StatelessWidget {
  const TicketListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final tp = Provider.of<TicketProvider>(context);
    final user = auth.currentUser!;
    final isUser = user.role == UserRole.user;

    final list = isUser
        ? tp.getTicketsForUser(user.id)
        : tp.filteredTickets;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'SEMUA TIKET',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.adaptiveText(context),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.adaptiveText(context),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Text(
                          '${list.length}',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.primary,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (isUser)
                    GestureDetector(
                      onTap: () => context.push('/create-ticket'),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          border: Border.all(color: AppTheme.adaptiveText(context), width: 3),
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(color: AppTheme.adaptiveText(context), offset: Offset(3, 3), blurRadius: 0),
                          ],
                        ),
                        child: Icon(Icons.add_rounded, color: AppTheme.adaptiveText(context), size: 22),
                      ),
                    ),
                ],
              ),
            ),

            // Filter (admin/helpdesk)
            if (!isUser)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['all', 'open', 'in progress', 'resolved', 'closed'].map((s) {
                      final selected = tp.filterStatus == s;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => tp.setFilterStatus(s),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: selected ? AppTheme.primary : AppTheme.adaptiveBackground(context),
                              borderRadius: BorderRadius.circular(2),
                              border: Border.all(color: AppTheme.adaptiveText(context), width: selected ? 3 : 2),
                              boxShadow: selected
                                  ? [BoxShadow(color: AppTheme.adaptiveText(context), offset: Offset(3, 3), blurRadius: 0)]
                                  : null,
                            ),
                            child: Text(
                              (s == 'all' ? 'SEMUA' : s).toUpperCase(),
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.adaptiveText(context),
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

            const SizedBox(height: 12),

            Expanded(
              child: list.isEmpty
                  ? const EmptyWidget(message: 'Belum ada tiket')
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) => TicketCardWidget(ticket: list[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}