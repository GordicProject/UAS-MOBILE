import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/auth_provider.dart';
import '../../providers/ticket_provider.dart';
import '../../providers/theme_provider.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/ticket_model.dart';
import '../../../core/theme/app_theme.dart';

class DashboardScreen extends StatefulWidget  {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final tp   = Provider.of<TicketProvider>(context, listen: false);
      final user = auth.currentUser!;

      if (user.role == UserRole.user) {
        tp.loadTicketsForUser(user.id);
      } else if (user.role == UserRole.helpdesk) {
        tp.loadTicketsForHelpdesk(user.id);
      } else {
        tp.loadAllTickets();
      }
    });
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 11) return 'PAGI';
    if (h < 15) return 'SIANG';
    if (h < 18) return 'SORE';
    return 'MALAM';
  }

  @override
  Widget build(BuildContext context) {
    final auth   = Provider.of<AuthProvider>(context);
    final tp     = Provider.of<TicketProvider>(context);
    final themeP = Provider.of<ThemeProvider>(context);
    final user   = auth.currentUser!;
    final isUser = user.role == UserRole.user;

    final displayTickets = isUser
        ? tp.getTicketsForUser(user.id)
        : tp.tickets;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.adaptiveText(context),
          backgroundColor: AppTheme.primary,
          onRefresh: () async => await Future.delayed(const Duration(milliseconds: 500)),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.adaptiveText(context),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Text(
                            '// ${_greeting()}',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.primary,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Halo, ${user.name.split(' ').first}!',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.adaptiveText(context),
                            letterSpacing: -1,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        _IconBtn(
                          icon: themeP.isDarkMode
                              ? Icons.light_mode_rounded
                              : Icons.dark_mode_rounded,
                          onTap: themeP.toggleTheme,
                        ),
                        const SizedBox(width: 8),
                        _IconBtn(
                          icon: Icons.notifications_outlined,
                          showDot: true,
                          onTap: () => context.push('/notifications'),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Stat Cards Brutalism ──
                Row(
                  children: [
                    _StatCard(
                      label: 'TOTAL',
                      value: displayTickets.length,
                      icon: Icons.confirmation_number_rounded,
                      color: AppTheme.primary,
                    ),
                    const SizedBox(width: 12),
                    _StatCard(
                      label: 'OPEN',
                      value: displayTickets.where((t) => t.status == TicketStatus.open).length,
                      icon: Icons.fiber_new_rounded,
                      color: AppTheme.acidPink,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _StatCard(
                      label: 'PROSES',
                      value: displayTickets.where((t) => t.status == TicketStatus.inProgress).length,
                      icon: Icons.sync_rounded,
                      color: AppTheme.acidOrange,
                    ),
                    const SizedBox(width: 12),
                    _StatCard(
                      label: 'DONE',
                      value: displayTickets.where((t) => t.status == TicketStatus.resolved).length,
                      icon: Icons.check_circle_rounded,
                      color: AppTheme.acidLime,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Bar Chart ──
                _BarChartCard(tickets: displayTickets),
                const SizedBox(height: 24),

                // ── Tiket Terbaru ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(width: 6, height: 22, color: AppTheme.adaptiveText(context)),
                        const SizedBox(width: 8),
                        Text(
                          'TIKET TERBARU',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.adaptiveText(context),
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => context.push('/tickets'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.adaptiveBackground(context),
                          border: Border.all(color: AppTheme.adaptiveText(context), width: 2),
                        ),
                        child: Text(
                          'SEMUA →',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 11,
                            color: AppTheme.adaptiveText(context),
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...displayTickets.take(3).map((t) => _RecentItem(
                      title: t.title,
                      id: t.id,
                      status: t.statusLabel,
                      onTap: () => context.push('/tickets/${t.id}'),
                    )),

                if (isUser) ...[
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => context.push('/create-ticket'),
                    icon: Icon(Icons.add, size: 22),
                    label: const Text('BUAT TIKET BARU'),
                  ),
                ],
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Bar Chart Card Brutalism ──
class _BarChartCard extends StatelessWidget {
  final List<TicketModel> tickets;
  const _BarChartCard({required this.tickets});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final days = List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));

    List<double> counts = days.map((day) {
      return tickets
          .where((t) =>
              t.createdAt.year == day.year &&
              t.createdAt.month == day.month &&
              t.createdAt.day == day.day)
          .length
          .toDouble();
    }).toList();

    final allZero = counts.every((c) => c == 0);
    if (allZero) counts = [2, 5, 1, 7, 3, 4, 2];

    final maxY = (counts.reduce((a, b) => a > b ? a : b) + 2).toDouble();
    final dayLabels = ['SEN', 'SEL', 'RAB', 'KAM', 'JUM', 'SAB', 'MIN'];

    return AppTheme.brutalContainer(
      context: context,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'STATISTIK',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.adaptiveText(context),
                  letterSpacing: 1,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  border: Border.all(color: AppTheme.adaptiveText(context), width: 2),
                ),
                child: Text(
                  '7 HARI',
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
          const SizedBox(height: 4),
          Text(
            'Total ${tickets.length} tiket',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 12,
              color: AppTheme.adaptiveTextSecondary(context),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                minY: 0,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 2,
                  getDrawingHorizontalLine: (v) => FlLine(
                    color: AppTheme.adaptiveText(context),
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: 2,
                      getTitlesWidget: (v, _) => Text(
                        '${v.toInt()}',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 10,
                          color: AppTheme.adaptiveText(context),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        final i = v.toInt();
                        if (i < 0 || i >= dayLabels.length) return const SizedBox();
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            dayLabels[i],
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 10,
                              color: AppTheme.adaptiveText(context),
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles:  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                barGroups: List.generate(7, (i) {
                  final isMax = counts[i] == counts.reduce((a, b) => a > b ? a : b);
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: counts[i],
                        width: 22,
                        borderRadius: BorderRadius.zero,
                        color: isMax ? AppTheme.primary : AppTheme.adaptiveText(context),
                      ),
                    ],
                  );
                }),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => AppTheme.ink,
                    getTooltipItem: (group, _, rod, __) => BarTooltipItem(
                      '${rod.toY.toInt()} TIKET',
                      GoogleFonts.spaceGrotesk(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Widgets kecil ──

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool showDot;

  const _IconBtn({required this.icon, required this.onTap, this.showDot = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppTheme.adaptiveBackground(context),
          border: Border.all(color: AppTheme.adaptiveText(context), width: 3),
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(color: AppTheme.adaptiveText(context), offset: Offset(3, 3), blurRadius: 0),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, size: 22, color: AppTheme.adaptiveText(context)),
            if (showDot)
              Positioned(
                top: 7, right: 7,
                child: Container(
                  width: 10, height: 10,
                  decoration: BoxDecoration(
                    color: AppTheme.acidRed,
                    border: Border.all(color: AppTheme.adaptiveText(context), width: 1.5),
                    shape: BoxShape.circle),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AppTheme.brutalContainer(
        context: context,
        backgroundColor: color,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: AppTheme.adaptiveText(context),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              '$value',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: AppTheme.adaptiveText(context),
                letterSpacing: -1,
                height: 1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 11,
                color: AppTheme.adaptiveText(context),
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentItem extends StatelessWidget {
  final String title;
  final String id;
  final String status;
  final VoidCallback onTap;

  const _RecentItem({
    required this.title, required this.id,
    required this.status, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppTheme.getStatusColor(status);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: AppTheme.adaptiveBackground(context),
          border: Border.all(color: AppTheme.adaptiveText(context), width: 3),
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(color: AppTheme.adaptiveText(context), offset: Offset(4, 4), blurRadius: 0),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: c,
                border: Border.all(color: AppTheme.adaptiveText(context), width: 2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(Icons.confirmation_number_outlined, color: AppTheme.adaptiveText(context), size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.adaptiveText(context),
                    ),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '#$id',
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: c,
                border: Border.all(color: AppTheme.adaptiveText(context), width: 2),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Text(
                status.toUpperCase(),
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
    );
  }
}
