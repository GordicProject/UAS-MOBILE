import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../data/models/ticket_model.dart';
import '../../core/theme/app_theme.dart';

class TicketCardWidget extends StatelessWidget {
  final TicketModel ticket;
  const TicketCardWidget({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    final statusColor = AppTheme.getStatusColor(ticket.statusLabel);
    final priorityColor = AppTheme.getPriorityColor(ticket.priorityLabel);

    return GestureDetector(
      onTap: () => context.push('/tickets/${ticket.id}'),
      child: AppTheme.brutalContainer(
        context: context,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (ticket.attachments != null && ticket.attachments!.isNotEmpty)
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.adaptiveText(context),
                      border: Border.all(color: AppTheme.adaptiveText(context), width: 2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: Image.memory(
                        ticket.attachments!.first,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                else
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: statusColor,
                      border: Border.all(color: AppTheme.adaptiveText(context), width: 2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      Icons.confirmation_number_outlined,
                      color: AppTheme.adaptiveText(context),
                      size: 18,
                    ),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ticket.title,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.adaptiveText(context),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '#${ticket.id}',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.adaptiveTextSecondary(context),
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                _StatusChip(label: ticket.statusLabel, color: statusColor),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _Tag(label: ticket.categoryLabel, color: AppTheme.acidPurple),
                const SizedBox(width: 6),
                _Tag(label: ticket.priorityLabel, color: priorityColor),
                const Spacer(),
                if (ticket.attachments != null && ticket.attachments!.isNotEmpty) ...[
                  Icon(Icons.attach_file_rounded, size: 14, color: AppTheme.adaptiveText(context)),
                  const SizedBox(width: 4),
                ],
                Text(
                  DateFormat('dd MMM').format(ticket.createdAt),
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 11,
                    color: AppTheme.adaptiveTextSecondary(context),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: AppTheme.adaptiveText(context), width: 2),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.spaceGrotesk(
          fontSize: 9,
          fontWeight: FontWeight.w900,
          color: AppTheme.adaptiveText(context),
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  const _Tag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.adaptiveBackground(context),
        border: Border.all(color: color, width: 1.5),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.spaceGrotesk(
          fontSize: 9,
          fontWeight: FontWeight.w900,
          color: color,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
