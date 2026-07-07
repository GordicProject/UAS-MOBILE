import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/screens/splash_screen.dart';
import '../../presentation/screens/login_screen.dart';
import '../../presentation/screens/register_screen.dart';
import '../../presentation/screens/reset_password_screen.dart';
import '../../presentation/screens/main_shell.dart';
import '../../presentation/screens/dashboard/dashboard_screen.dart';
import '../../presentation/screens/tickets/ticket_list_screen.dart';
import '../../presentation/screens/tickets/ticket_detail_screen.dart';
import '../../presentation/screens/tickets/create_ticket_screen.dart';
import '../../presentation/screens/notification_screen.dart';
import '../../presentation/screens/profile_screen.dart';
import '../../presentation/screens/admin/user_management_screen.dart';

class AppRouter {
  static GoRouter createRouter(BuildContext context) {
    return GoRouter(
      initialLocation: '/splash',
      redirect: (context, state) {
        final auth     = Provider.of<AuthProvider>(context, listen: false);
        final loggedIn = auth.currentUser != null;
        final onAuth   = ['/login', '/register', '/reset-password', '/splash']
            .contains(state.matchedLocation);
        if (!loggedIn && !onAuth) return '/login';
        if (loggedIn && state.matchedLocation == '/login') return '/dashboard';
        return null;
      },
      routes: [
        GoRoute(path: '/splash',         builder: (_, __) => const SplashScreen()),
        GoRoute(path: '/login',          builder: (_, __) => const LoginScreen()),
        GoRoute(path: '/register',       builder: (_, __) => const RegisterScreen()),
        GoRoute(path: '/reset-password', builder: (_, __) => const ResetPasswordScreen()),

        GoRoute(
          path: '/dashboard',
          builder: (_, __) => const MainShell(currentIndex: 0, child: DashboardScreen()),
        ),
        GoRoute(
          path: '/tickets',
          builder: (_, __) => const MainShell(currentIndex: 1, child: TicketListScreen()),
        ),
        GoRoute(
          path: '/tickets/:id',
          builder: (_, state) => MainShell(
            currentIndex: 1,
            child: TicketDetailScreen(ticketId: state.pathParameters['id']!),
          ),
        ),
        GoRoute(
          path: '/create-ticket',
          builder: (_, __) => const CreateTicketScreen(),
        ),
        GoRoute(
          path: '/notifications',
          builder: (_, __) => const MainShell(currentIndex: 2, child: NotificationScreen()),
        ),

        // ── Pengguna: index 3 (Admin saja) ──────────────────────────────
        GoRoute(
          path: '/admin/users',
          builder: (_, __) => const MainShell(currentIndex: 3, child: UserManagementScreen()),
        ),

        // ── Profil: index 4 untuk Admin, index 3 untuk Helpdesk ─────────
        // MainShell menangani highlight yang benar berdasarkan role,
        // jadi currentIndex di sini pakai 4 (nilai Admin).
        // Untuk Helpdesk, highlight Profil dicek via `isAdmin ? 4 : 3` di MainShell.
        GoRoute(
          path: '/profile',
          builder: (_, __) => const MainShell(currentIndex: null, child: ProfileScreen()),
        ),
      ],
    );
  }
}