import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart'; // ← tambahkan uuid ke pubspec.yaml jika belum ada
import '../../../core/theme/app_theme.dart';
import '../../../data/models/user_model.dart';
import '../../../services/supabase_service.dart';
import '../../../presentation/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  List<UserModel> _allUsers = [];
  bool _isLoading = true;
  String _filterRole = 'all';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final users = await SupabaseService().getAllUsers();
      setState(() {
        _allUsers = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Gagal memuat data pengguna: $e'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  List<UserModel> get _filteredUsers {
    if (_filterRole == 'all') return _allUsers;
    return _allUsers.where((u) => u.role.name == _filterRole).toList();
  }

  // ── DIALOG TAMBAH PENGGUNA ───────────────────────────────────────────────
  void _showAddUserDialog() {
    final nameCtrl     = TextEditingController();
    final emailCtrl    = TextEditingController();
    final passwordCtrl = TextEditingController();
    UserRole selectedRole = UserRole.user;
    bool obscure = true;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.person_add_outlined,
                    color: AppTheme.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text('Tambah Pengguna',
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
            ],
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Nama ──
                  Text('Nama', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      hintText: 'Nama lengkap',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Nama tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 14),

                  // ── Email ──
                  Text('Email', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'contoh@gmail.com',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Email tidak boleh kosong';
                      final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                      if (!regex.hasMatch(v.trim())) return 'Format email tidak valid';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // ── Password ──
                  Text('Password', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: passwordCtrl,
                    obscureText: obscure,
                    decoration: InputDecoration(
                      hintText: 'Min. 3 karakter',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      suffixIcon: IconButton(
                        icon: Icon(obscure
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined, size: 18),
                        onPressed: () => setDlgState(() => obscure = !obscure),
                      ),
                    ),
                    validator: (v) => (v == null || v.length < 3)
                        ? 'Password minimal 3 karakter' : null,
                  ),
                  const SizedBox(height: 14),

                  // ── Pilih Role ──
                  Text('Role', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Row(
                    children: UserRole.values.map((role) {
                      final isSelected = selectedRole == role;
                      final color = _roleColor(role);
                      final label = role == UserRole.user      ? 'User'
                          : role == UserRole.helpdesk  ? 'Helpdesk'
                          : 'Admin';
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: role != UserRole.admin ? 8 : 0),
                          child: GestureDetector(
                            onTap: () => setDlgState(() => selectedRole = role),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected ? color.withOpacity(0.12) : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected ? color : Colors.grey.shade300,
                                  width: isSelected ? 1.5 : 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(_roleIcon(role), size: 18,
                                      color: isSelected ? color : Colors.grey),
                                  const SizedBox(height: 4),
                                  Text(label,
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                        color: isSelected ? color : Colors.grey,
                                      )),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal', style: GoogleFonts.inter(color: AppTheme.adaptiveTextSecondary(context))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                Navigator.pop(context);
                await _addUser(
                  name:     nameCtrl.text.trim(),
                  email:    emailCtrl.text.trim(),
                  password: passwordCtrl.text,
                  role:     selectedRole,
                );
              },
              child: Text('Tambah',
                  style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addUser({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    try {
      // Cek email duplikat
      final existing = _allUsers.any((u) => u.email == email);
      if (existing) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Email sudah terdaftar'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ));
        }
        return;
      }

      // ── PERBAIKAN UTAMA: gunakan UUID yang valid ──
      // Kolom id di Supabase bertipe UUID, bukan TEXT biasa.
      // DateTime.millisecondsSinceEpoch menghasilkan angka biasa → error 400.
      final newId = const Uuid().v4(); // contoh: "550e8400-e29b-41d4-a716-446655440000"

      final newUser = UserModel(
        id:        newId,
        name:      name,
        email:     email,
        password:  password,
        role:      role,
        createdAt: DateTime.now(),
      );
      await SupabaseService().createUser(newUser);

      // Buat notifikasi (ticketId=null supaya tidak kena FK constraint ke tabel tickets)
      final uuid = Uuid();
      try {
        await SupabaseService().addNotification(
          id:      'n-new-user-${uuid.v4()}',
          title:   'Pengguna Baru Ditambahkan',
          message: 'Pengguna baru "$name" dengan role "${role.name}" telah ditambahkan ke sistem.',
        );
      } catch (_) { /* notif gagal jangan block alur */ }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Pengguna $name berhasil ditambahkan'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ));
      await _loadUsers();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Gagal menambahkan pengguna: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  // ── DIALOG HAPUS PENGGUNA ───────────────────────────────────────────────
  void _showDeleteDialog(UserModel user) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Pengguna?'),
        content: Text(
          'Apakah kamu yakin ingin MENGHAPUS akun ${user.name} dari database?\n\n'
              'Tindakan ini tidak dapat dibatalkan. '
              'Jika pengguna ini pernah membuat tiket, penghapusan akan gagal '
              'karena ada data yang terkait.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              await _deleteUser(user);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteUser(UserModel user) async {
    try {
      await SupabaseService().deleteUser(user.id);

      // Buat notifikasi (best-effort)
      try {
        final uuid = Uuid();
        await SupabaseService().addNotification(
          id:      'n-delete-${uuid.v4()}',
          title:   'Pengguna Dihapus',
          message: 'Pengguna "$user.name" telah dihapus dari sistem oleh admin.',
        );
      } catch (_) { /* notif gagal jangan block alur */ }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Akun ${user.name} berhasil dihapus'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ));
      await _loadUsers();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Gagal menghapus: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  // ── DIALOG TOGGLE AKTIF / NONAKTIF ───────────────────────────────────────
  void _showToggleActiveDialog(UserModel user) {
    final bool isActive = user.isActive;
    final String title     = isActive ? 'Nonaktifkan Pengguna?' : 'Aktifkan Pengguna?';
    final String message   = isActive
        ? 'Pengguna tidak akan bisa login, tetapi datanya tetap tersimpan di database.'
        : 'Pengguna akan dapat login kembali seperti biasa.';
    final String btnText   = isActive ? 'Nonaktifkan' : 'Aktifkan';
    final Color  btnColor  = isActive ? Colors.orange : Colors.green;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title),
        content: Text('Apakah kamu yakin ingin $btnText akun ${user.name}?\n\n$message'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: btnColor),
            onPressed: () async {
              Navigator.pop(context);
              await _toggleActive(user);
            },
            child: Text(btnText, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleActive(UserModel user) async {
    final bool willActivate = !user.isActive;
    // ignore: avoid_print
    print('[TOGGLE] user=${user.email} isActive=${user.isActive} -> willActivate=$willActivate');
    try {
      if (willActivate) {
        await SupabaseService().activateUser(user.id);
      } else {
        await SupabaseService().deactivateUser(user.id);
      }
      // ignore: avoid_print
      print('[TOGGLE] OK -> ${willActivate ? 'activated' : 'deactivated'} ${user.email}');

      // Buat notifikasi (best-effort)
      try {
        final uuid = Uuid();
        final String action = willActivate ? 'diaktifkan' : 'dinonaktifkan';
        final String title  = willActivate ? 'Pengguna Diaktifkan' : 'Pengguna Dinonaktifkan';
        await SupabaseService().addNotification(
          id:      'n-active-${uuid.v4()}',
          title:   title,
          message: 'Pengguna "$user.name" telah $action oleh admin.',
        );
      } catch (_) { /* notif gagal jangan block alur */ }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Akun ${user.name} berhasil ${willActivate ? 'diaktifkan' : 'dinonaktifkan'}'),
        backgroundColor: willActivate ? Colors.green : Colors.orange,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ));
      await _loadUsers();
    } catch (e) {
      // ignore: avoid_print
      print('[TOGGLE] FAILED: $e');
      if (mounted) {
        String msg = e.toString();
        // Pesan yang lebih user-friendly untuk error umum
        if (msg.contains('is_active') || msg.contains('column')) {
          msg = 'Kolom is_active belum ada di database.\n'
                'Jalankan di Supabase SQL Editor:\n'
                'ALTER TABLE users ADD COLUMN is_active BOOLEAN DEFAULT TRUE;';
        } else if (msg.contains('policy') || msg.contains('RLS')) {
          msg = 'Akses ditolak oleh Row Level Security.\n'
                'Cek policy di Supabase → Authentication → Policies → users';
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Gagal: $msg'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 6),
        ));
      }
    }
  }

  // ── DIALOG GANTI ROLE ─────────────────────────────────────────────────
  void _showChangeRoleDialog(UserModel user) {
    UserRole selectedRole = user.role;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.swap_horiz_rounded,
                    color: AppTheme.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Ganti Role',
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          content: Form(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info user
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: _roleColor(user.role).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              user.name[0].toUpperCase(),
                              style: GoogleFonts.inter(
                                  fontSize: 14, fontWeight: FontWeight.w700,
                                  color: _roleColor(user.role)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user.name,
                                  style: GoogleFonts.inter(
                                      fontSize: 13, fontWeight: FontWeight.w600)),
                              Text(user.email,
                                  style: GoogleFonts.inter(
                                      fontSize: 11, color: AppTheme.adaptiveTextSecondary(context)),
                                  maxLines: 1, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Role saat ini: ${user.roleName}',
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _roleColor(user.role))),
                  const SizedBox(height: 12),
                  Text('Pilih role baru',
                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 10),

                  // Role options
                  Column(
                    children: UserRole.values.map((role) {
                      final isSelected = selectedRole == role;
                      final isCurrent = role == user.role;
                      final color = _roleColor(role);
                      final label = role == UserRole.user      ? 'User'
                          : role == UserRole.helpdesk  ? 'Helpdesk'
                          : 'Admin';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: GestureDetector(
                          onTap: () => setDlgState(() => selectedRole = role),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? color.withOpacity(0.12) : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected ? color : Colors.grey.shade300,
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(_roleIcon(role), size: 20,
                                    color: isSelected ? color : Colors.grey),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(label,
                                          style: GoogleFonts.inter(
                                              fontSize: 13,
                                              fontWeight: isSelected
                                                  ? FontWeight.w700
                                                  : FontWeight.w500,
                                              color: isSelected ? color : null)),
                                      Text(_roleDescription(role),
                                          style: GoogleFonts.inter(
                                              fontSize: 11, color: AppTheme.adaptiveTextSecondary(context))),
                                    ],
                                  ),
                                ),
                                if (isCurrent)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text('SAAT INI',
                                        style: GoogleFonts.inter(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w700,
                                            color: AppTheme.adaptiveText(context),
                                            letterSpacing: 0.5)),
                                  ),
                                if (isSelected && !isCurrent)
                                  Icon(Icons.check_circle, color: color, size: 18),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal', style: GoogleFonts.inter(color: AppTheme.adaptiveTextSecondary(context))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onPressed: selectedRole == user.role
                  ? null
                  : () async {
                      Navigator.pop(context);
                      await _changeUserRole(user, selectedRole);
                    },
              child: Text('Simpan',
                  style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _changeUserRole(UserModel user, UserRole newRole) async {
    try {
      await SupabaseService().updateUserRole(user.id, newRole);

      // Ambil nama admin yang sedang login
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final adminName = authProvider.currentUser?.name ?? 'Admin';

      // Buat notifikasi tentang perubahan role
      try {
        final uuid = Uuid();
        await SupabaseService().addNotification(
          id:      'n-role-${uuid.v4()}',
          title:   'Role Pengguna Diubah',
          message: '$adminName mengubah role "$user.name" dari "${user.role.name}" menjadi "${newRole.name}".',
        );
      } catch (_) { /* notif gagal jangan block alur */ }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Role ${user.name} diubah menjadi ${newRole.name}'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ));
      await _loadUsers();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Gagal mengubah role: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  String _roleDescription(UserRole role) {
    switch (role) {
      case UserRole.user:     return 'Pengguna biasa — buat & lihat tiket sendiri';
      case UserRole.helpdesk: return 'Agent — handle tiket yang di-assign';
      case UserRole.admin:    return 'Administrator — akses penuh sistem';
    }
  }

  // ── HELPER ──────────────────────────────────────────────────────────────
  Color _roleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:    return Colors.purple;
      case UserRole.helpdesk: return Colors.orange;
      case UserRole.user:     return AppTheme.primary;
    }
  }

  IconData _roleIcon(UserRole role) {
    switch (role) {
      case UserRole.admin:    return Icons.admin_panel_settings_outlined;
      case UserRole.helpdesk: return Icons.headset_mic_outlined;
      case UserRole.user:     return Icons.person_outline_rounded;
    }
  }

  // ── BUILD ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final filtered = _filteredUsers;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddUserDialog,
        backgroundColor: AppTheme.primary,
        icon: Icon(Icons.person_add_outlined, color: Colors.white),
        label: Text('Tambah',
            style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Kelola Pengguna',
                      style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700)),
                  GestureDetector(
                    onTap: _loadUsers,
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardTheme.color,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Theme.of(context).dividerTheme.color!),
                      ),
                      child: Icon(Icons.refresh_rounded, size: 20),
                    ),
                  ),
                ],
              ),
            ),

            // ── Summary Cards ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _SummaryCard(label: 'Total',    value: _allUsers.length,                                             color: AppTheme.primary),
                  const SizedBox(width: 10),
                  _SummaryCard(label: 'User',     value: _allUsers.where((u) => u.role == UserRole.user).length,     color: Colors.blue),
                  const SizedBox(width: 10),
                  _SummaryCard(label: 'Helpdesk', value: _allUsers.where((u) => u.role == UserRole.helpdesk).length, color: Colors.orange),
                  const SizedBox(width: 10),
                  _SummaryCard(label: 'Admin',    value: _allUsers.where((u) => u.role == UserRole.admin).length,    color: Colors.purple),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Filter Chip ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['all', 'user', 'helpdesk', 'admin'].map((role) {
                    final selected = _filterRole == role;
                    final label   = role == 'all' ? 'Semua' : role;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _filterRole = role),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: selected ? AppTheme.primary : Theme.of(context).cardTheme.color,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: selected ? AppTheme.primary : Theme.of(context).dividerTheme.color!,
                            ),
                          ),
                          child: Text(
                            label[0].toUpperCase() + label.substring(1),
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: selected ? AppTheme.ink : null,
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

            // ── Daftar Pengguna ──
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filtered.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.people_outline, size: 56, color: AppTheme.adaptiveTextSecondary(context)),
                    const SizedBox(height: 12),
                    Text('Tidak ada pengguna',
                        style: GoogleFonts.inter(color: AppTheme.adaptiveTextSecondary(context))),
                  ],
                ),
              )
                  : RefreshIndicator(
                onRefresh: _loadUsers,
                color: AppTheme.primary,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _UserCard(
                    user:         filtered[i],
                    onDeactivate: () => _showToggleActiveDialog(filtered[i]),
                    onDelete:    () => _showDeleteDialog(filtered[i]),
                    onChangeRole: () => _showChangeRoleDialog(filtered[i]),
                    roleColor:    _roleColor(filtered[i].role),
                    roleIcon:     _roleIcon(filtered[i].role),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── CARD PENGGUNA ────────────────────────────────────────────────────────

class _UserCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback onDeactivate;
  final VoidCallback onDelete;
  final VoidCallback onChangeRole;
  final Color roleColor;
  final IconData roleIcon;

  const _UserCard({
    required this.user,
    required this.onDeactivate,
    required this.onDelete,
    required this.onChangeRole,
    required this.roleColor,
    required this.roleIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).dividerTheme.color!),
      ),
      child: Row(
        children: [
          // Avatar inisial
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(
              color: roleColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                user.name[0].toUpperCase(),
                style: GoogleFonts.inter(
                    fontSize: 18, fontWeight: FontWeight.w700, color: roleColor),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Info nama & email
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.name,
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(user.email,
                    style: GoogleFonts.inter(fontSize: 12, color: AppTheme.adaptiveTextSecondary(context)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: roleColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(roleIcon, size: 12, color: roleColor),
                      const SizedBox(width: 4),
                      Text(user.roleName,
                          style: GoogleFonts.inter(
                              fontSize: 11, fontWeight: FontWeight.w600, color: roleColor)),
                    ],
                  ),
                ),
                if (!user.isActive) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.block_rounded, size: 12, color: Colors.orange.shade800),
                        const SizedBox(width: 4),
                        Text('Nonaktif',
                            style: GoogleFonts.inter(
                                fontSize: 11, fontWeight: FontWeight.w600, color: Colors.orange.shade800)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Tombol aksi — tidak tampil untuk admin
          if (user.role != UserRole.admin)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Ganti role
                IconButton(
                  tooltip: 'Ganti role',
                  icon: Icon(Icons.swap_horiz_rounded, color: AppTheme.primary, size: 20),
                  onPressed: () => onChangeRole(),
                ),
                const SizedBox(width: 4),
                // Toggle Aktif / Nonaktif
                IconButton(
                  tooltip: user.isActive ? 'Nonaktifkan pengguna' : 'Aktifkan pengguna',
                  icon: Icon(
                    user.isActive ? Icons.block_rounded : Icons.check_circle_rounded,
                    color: user.isActive ? Colors.orange : Colors.green,
                    size: 20,
                  ),
                  onPressed: onDeactivate,
                ),
                const SizedBox(width: 4),
                // Hapus permanen
                IconButton(
                  tooltip: 'Hapus pengguna',
                  icon: Icon(Icons.delete_rounded, color: Colors.red, size: 20),
                  onPressed: onDelete,
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// ─── SUMMARY CARD ─────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _SummaryCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text('$value',
                style: GoogleFonts.inter(
                    fontSize: 20, fontWeight: FontWeight.w700, color: color)),
            Text(label,
                style: GoogleFonts.inter(fontSize: 11, color: color.withOpacity(0.8))),
          ],
        ),
      ),
    );
  }
}