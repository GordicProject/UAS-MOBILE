import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/ticket_provider.dart';
import '../../core/theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final themeP = Provider.of<ThemeProvider>(context);
    final tp = Provider.of<TicketProvider>(context);
    final user = auth.currentUser!;
    final myTickets = tp.getTicketsForUser(user.id);

    return Scaffold(
      backgroundColor: AppTheme.adaptiveBackground(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.adaptiveText(context), width: 3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.adaptiveText(context), size: 18),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'PROFIL SAYA',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.adaptiveText(context),
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Avatar & info brutalism
              AppTheme.brutalContainer(
                context: context,
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppTheme.adaptiveText(context),
                        border: Border.all(color: AppTheme.adaptiveText(context), width: 3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: Text(
                          user.name[0].toUpperCase(),
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.primary,
                            letterSpacing: -1,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name.toUpperCase(),
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.adaptiveText(context),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user.email,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 12,
                              color: AppTheme.adaptiveTextSecondary(context),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.primary,
                              border: Border.all(color: AppTheme.adaptiveText(context), width: 2),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Text(
                              user.roleName.toUpperCase(),
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
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Stat tiket brutalism
              Row(
                children: [
                  _BrutStatCard(label: 'TOTAL', value: myTickets.length),
                  const SizedBox(width: 10),
                  _BrutStatCard(label: 'OPEN', value: myTickets.where((t) => t.status.name == 'open').length),
                  const SizedBox(width: 10),
                  _BrutStatCard(label: 'DONE', value: myTickets.where((t) => t.status.name == 'resolved' || t.status.name == 'closed').length),
                ],
              ),
              const SizedBox(height: 24),

              // Settings
              Row(
                children: [
                  Container(width: 4, height: 18, color: AppTheme.adaptiveText(context)),
                  const SizedBox(width: 6),
                  Text(
                    'PENGATURAN',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.adaptiveText(context),
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: themeP.isDarkMode ? AppTheme.acidLime : AppTheme.acidPurple,
                  border: Border.all(color: AppTheme.adaptiveText(context), width: 2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  themeP.isDarkMode ? 'DARK' : 'LIGHT',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.adaptiveText(context),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              _SettingTile(
                icon: themeP.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                label: 'DARK MODE',
                trailing: Switch(
                  value: themeP.isDarkMode,
                  onChanged: (_) {
                    themeP.toggleTheme();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(themeP.isDarkMode ? 'Dark Mode ON' : 'Light Mode ON'),
                        backgroundColor: AppTheme.acidLime,
                        duration: const Duration(milliseconds: 500),
                      ),
                    );
                  },
                  activeTrackColor: AppTheme.acidLime,
                  activeColor: AppTheme.adaptiveText(context),
                ),
              ),
              _SettingTile(
                icon: Icons.notifications_outlined,
                label: 'NOTIFIKASI',
                trailing: Icon(Icons.chevron_right, size: 20, color: AppTheme.adaptiveText(context)),
                onTap: () => context.push('/notifications'),
              ),
              const SizedBox(height: 24),

              // Logout brutalism
              GestureDetector(
                onTap: () {
                  auth.logout();
                  context.go('/login');
                },
                child: AppTheme.brutalContainer(
                  context: context,
                  backgroundColor: AppTheme.acidRed,
                  padding: const EdgeInsets.all(16),
                  shadows: [BoxShadow(color: AppTheme.adaptiveText(context), offset: const Offset(6, 6), blurRadius: 0)],
                  child: Row(
                    children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: AppTheme.adaptiveText(context),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Icon(Icons.logout_rounded, color: AppTheme.acidRed, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        'KELUAR',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.adaptiveText(context),
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrutStatCard extends StatelessWidget {
  final String label;
  final int value;
  const _BrutStatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AppTheme.brutalContainer(
        context: context,
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Text(
              '$value',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: AppTheme.adaptiveText(context),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AppTheme.adaptiveTextSecondary(context),
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget trailing;
  final VoidCallback? onTap;

  const _SettingTile({required this.icon, required this.label, required this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AppTheme.brutalContainer(
        context: context,
        backgroundColor: AppTheme.adaptiveBackground(context),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: AppTheme.primary,
                border: Border.all(color: AppTheme.adaptiveText(context), width: 2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(icon, size: 18, color: AppTheme.adaptiveText(context)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.adaptiveText(context),
                  letterSpacing: 0.5,
                ),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
