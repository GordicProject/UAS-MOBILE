import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../../data/models/user_model.dart';
import '../../core/theme/app_theme.dart';

class MainShell extends StatelessWidget {
  final int? currentIndex;
  final Widget child;

  const MainShell({
    super.key,
    required this.currentIndex,
    required this.child,
  }) : assert(currentIndex == null || currentIndex >= 0);

  @override
  Widget build(BuildContext context) {
    final auth   = Provider.of<AuthProvider>(context);
    final user   = auth.currentUser!;
    final isUser = user.role == UserRole.user;

    // Tentukan index highlight dari lokasi route saat ini
    final loc = GoRouterState.of(context).matchedLocation;
    final selectedIdx = currentIndex ?? _inferIndex(loc, isUser);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.adaptiveBackground(context),
          border: Border(
            top: BorderSide(color: AppTheme.adaptiveText(context), width: 4),
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 72,
            child: isUser
                ? _buildUserNav(context, selectedIdx)
                : _buildAdminHelpdeskNav(context, user.role, selectedIdx),
          ),
        ),
      ),
    );
  }

  Widget _buildUserNav(BuildContext context, int selectedIdx) {
    return Row(
      children: [
        _NavItem(
          icon: Icons.grid_view_rounded,
          label: 'BERANDA',
          selected: selectedIdx == 0,
          onTap: () => context.go('/dashboard'),
        ),
        _NavItem(
          icon: Icons.list_alt_rounded,
          label: 'TIKET',
          selected: selectedIdx == 1,
          onTap: () => context.go('/tickets'),
        ),
        // Tombol + tengah — button brutalism
        Expanded(
          child: GestureDetector(
            onTap: () => context.push('/create-ticket'),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    border: Border.all(color: AppTheme.adaptiveText(context), width: 3),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.adaptiveText(context),
                        offset: Offset(3, 3),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Icon(Icons.add, color: AppTheme.adaptiveText(context), size: 28),
                ),
              ],
            ),
          ),
        ),
        _NavItem(
          icon: Icons.notifications_outlined,
          label: 'INFO',
          selected: selectedIdx == 2,
          onTap: () => context.go('/notifications'),
        ),
        _NavItem(
          icon: Icons.person_outline_rounded,
          label: 'PROFIL',
          selected: selectedIdx == 3,
          onTap: () => context.go('/profile'),
        ),
      ],
    );
  }

  Widget _buildAdminHelpdeskNav(BuildContext context, UserRole role, int selectedIdx) {
    final isAdmin = role == UserRole.admin;
    return Row(
      children: [
        _NavItem(
          icon: Icons.grid_view_rounded,
          label: 'BERANDA',
          selected: selectedIdx == 0,
          onTap: () => context.go('/dashboard'),
        ),
        _NavItem(
          icon: Icons.list_alt_rounded,
          label: 'TIKET',
          selected: selectedIdx == 1,
          onTap: () => context.go('/tickets'),
        ),
        _NavItem(
          icon: Icons.notifications_outlined,
          label: 'INFO',
          selected: selectedIdx == 2,
          onTap: () => context.go('/notifications'),
        ),
        if (isAdmin)
          _NavItem(
            icon: Icons.people_outline_rounded,
            label: 'USER',
            selected: selectedIdx == 3,
            onTap: () => context.go('/admin/users'),
          ),
        _NavItem(
          icon: Icons.person_outline_rounded,
          label: 'PROFIL',
          selected: selectedIdx == (isAdmin ? 4 : 3),
          onTap: () => context.go('/profile'),
        ),
      ],
    );
  }

  int _inferIndex(String loc, bool isUser) {
    if (loc.startsWith('/dashboard')) return 0;
    if (loc.startsWith('/tickets'))   return 1;
    if (loc.startsWith('/notifications')) return 2;
    if (loc.startsWith('/admin/users')) return 3;
    if (loc.startsWith('/profile')) return isUser ? 3 : 4;
    return 0;
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppTheme.adaptiveText(context) : AppTheme.adaptiveTextSecondary(context);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: selected ? AppTheme.primary : Colors.transparent,
                border: selected
                    ? Border.all(color: AppTheme.adaptiveText(context), width: 2)
                    : Border.all(color: Colors.transparent, width: 2),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Icon(icon, color: AppTheme.adaptiveText(context), size: 20),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 9,
                fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                color: color,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
