# 09 — Dokumentasi Kode

Dokumen ini menjelaskan struktur kode, modul-modul penting, dan snippet kunci untuk reviewer/penguji.

## 9.1 Statistik Kode

| Metric | Nilai |
|---|---|
| Total file Dart | ~50 |
| Total baris kode (lib/) | ~5000 |
| File tersingkat | `empty_widget.dart` (~15 baris) |
| File terpanjang | `ticket_detail_screen.dart` (~600 baris) |
| Provider | 3 (Auth, Ticket, Theme) |
| Model | 6 (User, Ticket, Comment, History, Notification, Attachment) |
| Service | 1 (SupabaseService — singleton) |

## 9.2 Modul-Modul Kunci

### 9.2.1 `lib/main.dart` — Entry Point

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TicketProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp.router(
      title: 'E-Ticketing Helpdesk',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      routerConfig: AppRouter.createRouter(context),
    );
  }
}
```

**Yang terjadi di sini:**
1. Init Supabase client (satu kali di app lifecycle)
2. Setup Provider tree (3 global providers)
3. Theme membaca dari `ThemeProvider.mode`
4. Routing config dari `AppRouter`

### 9.2.2 `lib/services/supabase_service.dart` — Semua Operasi DB

Singleton class dengan ~25 method. Method-method utamanya:

```dart
class SupabaseService {
  final _db = Supabase.instance.client;

  // ── AUTH ──
  Future<UserModel?> login(String email, String password) async { ... }
  Future<UserModel?> getUserById(String id) async { ... }
  Future<List<UserModel>> getAllUsers() async { ... }

  // ── TICKETS ──
  Future<List<TicketModel>> getAllTickets() async { ... }
  Future<List<TicketModel>> getTicketsByUser(String userId) async { ... }
  Future<List<TicketModel>> getTicketsAssignedTo(String userId) async { ... }
  Future<void> createTicket({...}) async { ... }
  Future<void> updateTicketStatus({...}) async { ... }

  // ── COMMENTS ──
  Future<void> addComment({...}) async { ... }

  // ── NOTIFICATIONS ──
  Future<List<NotificationModel>> getNotifications() async { ... }
  Future<void> addNotification({...}) async { ... }
  Future<void> markNotificationRead(String id) async { ... }
  Future<void> markAllNotificationsRead() async { ... }

  // ── ATTACHMENTS ──
  Future<String?> uploadAttachment({...}) async { ... }

  // ── ADMIN: USER MANAGEMENT ──
  Future<void> updateUserRole({...}) async { ... }
  Future<void> deactivateUser(String userId) async { ... }
  Future<void> activateUser(String userId) async { ... }
  Future<void> deleteUser(String userId) async { ... }
}
```

**Pola yang konsisten:**
- Method `get*` → return list atau model
- Method `create*` / `update*` / `delete*` → return void (throw exception kalau gagal)
- Method yang trigger notifikasi → lakukan INSERT ke `notifications` setelah operasi utama
- Error handling: biarkan exception naik ke level Provider/Screen

### 9.2.3 `lib/presentation/providers/auth_provider.dart` — State Auth

```dart
class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final user = await SupabaseService().login(email, password);
      if (user == null) {
        _errorMessage = 'Email atau password salah';
        return false;
      }
      _currentUser = user;
      return true;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan, coba lagi';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
```

**Pola:** setiap method yang mengubah state → `_isLoading = true` → `notifyListeners()` → lakukan async → `_isLoading = false` → `notifyListeners()`. UI yang listen ke provider otomatis re-build.

### 9.2.4 `lib/presentation/providers/ticket_provider.dart` — State Tiket

Menyimpan list tiket + state CRUD. Method-method: `getAllTickets`, `getMyTickets`, `createTicket`, `updateStatus`, `addComment`, `getNotifications`, `markRead`, `markAllRead`, `refresh`.

```dart
class TicketProvider extends ChangeNotifier {
  List<TicketModel> _tickets = [];
  bool _isLoading = false;

  List<TicketModel> get tickets => _tickets;
  bool get isLoading => _isLoading;

  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();
    final svc = SupabaseService();
    _tickets = await svc.getAllTickets();
    _isLoading = false;
    notifyListeners();
  }

  // Statistik untuk Dashboard
  int countByStatus(TicketStatus s) =>
      _tickets.where((t) => t.status == s).length;
}
```

### 9.2.5 `lib/core/router/app_router.dart` — Konfigurasi Routing

```dart
class AppRouter {
  static GoRouter createRouter(BuildContext context) {
    return GoRouter(
      initialLocation: '/splash',
      redirect: (ctx, state) {
        // Auth guard
        final auth = Provider.of<AuthProvider>(ctx, listen: false);
        final loggedIn = auth.currentUser != null;
        final onAuth = ['/login', '/register', '/reset-password', '/splash']
            .contains(state.matchedLocation);
        if (!loggedIn && !onAuth) return '/login';
        if (loggedIn && state.matchedLocation == '/login') return '/dashboard';
        return null;
      },
      routes: [
        GoRoute(path: '/splash', ...),
        GoRoute(path: '/login', ...),
        GoRoute(path: '/tickets', ...),
        // dst
      ],
    );
  }
}
```

**Auth guard pattern:** redirect callback cek state login → redirect ke `/login` atau `/dashboard`.

### 9.2.6 `lib/core/theme/app_theme.dart` — Design System

```dart
class AppTheme {
  // Colors
  static const Color primary        = Color(0xFFFFD700);
  static const Color ink            = Color(0xFF000000);
  // dst

  // Text theme
  static TextTheme _textTheme(Color text) =>
      GoogleFonts.spaceGroteskTextTheme().copyWith(...);

  // Themes
  static ThemeData light() => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(seedColor: primary),
        textTheme: _textTheme(textPrimaryLight),
        cardTheme: CardTheme(
          shape: RoundedRectangleBorder(
            side: BorderSide(color: ink, width: 3),
            borderRadius: BorderRadius.circular(4),
          ),
          elevation: 0,
        ),
      );

  static ThemeData dark() => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.dark,
        ),
        textTheme: _textTheme(textPrimaryDark),
      );
}
```

**Adaptif helper:**
```dart
static Color adaptiveBackground(BuildContext ctx) =>
    Theme.of(ctx).brightness == Brightness.dark ? backgroundDark : backgroundLight;
```

## 9.3 Models

### 9.3.1 `UserModel`
```dart
enum UserRole { user, helpdesk, admin }

class UserModel {
  final String id;
  final String name;
  final String email;
  final String password;
  final UserRole role;
  final String? avatarUrl;
  final DateTime createdAt;
  final bool isActive;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      password: json['password'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => UserRole.user,
      ),
      avatarUrl: json['avatar_url'],
      createdAt: DateTime.parse(json['created_at']),
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'role': role.name,
    // ...
  };
}
```

### 9.3.2 `TicketModel` (paling kompleks)
```dart
enum TicketStatus   { open, inProgress, resolved, closed }
enum TicketPriority { low, medium, high }
enum TicketCategory { hardware, software, network, other }

class TicketModel {
  final String id;
  final String title;
  final String description;
  final TicketCategory category;
  final TicketPriority priority;
  final TicketStatus status;
  final String createdBy;
  final String? assignedTo;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Relasi (opsional, diload terpisah)
  final List<CommentModel> comments;
  final List<HistoryModel> history;
  final List<AttachmentModel> attachments;

  TicketModel({...});

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      category: TicketCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => TicketCategory.other,
      ),
      priority: TicketPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => TicketPriority.medium,
      ),
      status: TicketStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TicketStatus.open,
      ),
      createdBy: json['created_by'],
      assignedTo: json['assigned_to'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      comments: (json['comments'] as List?)
              ?.map((c) => CommentModel.fromJson(c))
              .toList() ?? [],
      history: (json['ticket_history'] as List?)
              ?.map((h) => HistoryModel.fromJson(h))
              .toList() ?? [],
      attachments: (json['ticket_attachments'] as List?)
              ?.map((a) => AttachmentModel.fromJson(a))
              .toList() ?? [],
    );
  }
}
```

## 9.4 Snippet Penting

### 9.4.1 ID Generator

```dart
String _generateTicketId() {
  return 'T-${DateTime.now().millisecondsSinceEpoch}';
}
```

Untuk demo UAS, format timestamp cukup unik dan mudah dilacak di database. Untuk production, UUID tetap lebih ideal.

### 9.4.2 Lifecycle Refresh Notifikasi

```dart
class _NotificationScreenState extends State<NotificationScreen>
    with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadNotifications();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadNotifications();   // refresh saat user kembali ke app
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
```

### 9.4.3 Pull-to-Refresh

```dart
RefreshIndicator(
  onRefresh: () => Provider.of<TicketProvider>(context, listen: false).refresh(),
  child: ListView.builder(
    itemCount: tickets.length,
    itemBuilder: (_, i) => TicketCard(ticket: tickets[i]),
  ),
)
```

### 9.4.4 Brutalist Card

```dart
Container(
  decoration: BoxDecoration(
    color: AppTheme.surfaceLight,
    border: Border.all(color: AppTheme.ink, width: 3),
    borderRadius: BorderRadius.circular(4),
    boxShadow: [
      BoxShadow(
        color: AppTheme.ink,
        offset: Offset(4, 4),
        blurRadius: 0,  // hard shadow
      ),
    ],
  ),
  padding: EdgeInsets.all(16),
  child: child,
)
```

### 9.4.5 Conditional Render per Role

```dart
Widget _buildActionButtons() {
  final user = context.read<AuthProvider>().currentUser;
  if (user == null) return SizedBox.shrink();

  if (user.role == UserRole.user) {
    return TextButton(
      onPressed: _addComment,
      child: Text('Tambah Komentar'),
    );
  } else if (user.role == UserRole.helpdesk || user.role == UserRole.admin) {
    return Row(
      children: [
        ElevatedButton(
          onPressed: _changeStatus,
          child: Text('Ubah Status'),
        ),
        SizedBox(width: 8),
        TextButton(
          onPressed: _addComment,
          child: Text('Tambah Komentar'),
        ),
      ],
    );
  }
  return SizedBox.shrink();
}
```

### 9.4.6 Error Snackbar

```dart
void _showError(BuildContext ctx, String msg) {
  ScaffoldMessenger.of(ctx).showSnackBar(
    SnackBar(
      content: Text(msg),
      backgroundColor: Colors.red,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(4),
      ),
    ),
  );
}
```

## 9.5 Alasan Teknis

### Kenapa Provider, bukan Bloc/Riverpod?
- Paling sederhana, paling banyak tutorial
- Bawaan flutter package
- Tidak perlu code generation
- Untuk skala UAS, sudah cukup

### Kenapa Supabase, bukan Firebase?
- Postgres SQL (familiar, type-safe)
- RLS built-in
- Storage lebih mudah
- Free tier generous

### Kenapa Neo-Brutalism?
- Out-of-the-box, mudah dikenali
- Tidak perlu Material default yang itu-itu saja
- Variasi dari desain UAS yang biasanya flat/minimalis

### Kenapa single `SupabaseService` (bukan multi-repository)?
- Untuk scope UAS, file ini cukup jelas
- Tidak perlu abstraksi berlebihan
- Kalau mau scale, bisa refactor per-table repository

## 9.6 Testing (Yang Sudah / Belum)

| Tipe | Status | Catatan |
|---|---|---|
| Unit test | ❌ Belum | - |
| Widget test | ❌ Belum | - |
| Integration test | ❌ Belum | - |
| Manual E2E | ✅ Sudah | Alur login → buat tiket → ubah status → notifikasi |

Untuk UAS, testing manual end-to-end dianggap cukup. Penguji tinggal mengikuti skenario di [06-fitur.md](06-fitur.md) §6.6.

## 9.7 Limitasi Kode yang Diketahui

1. **Password plain text** — untuk demo, tidak ada bcrypt/argon2. Tidak aman untuk production.
2. **No optimistic UI** — setiap aksi tunggu response Supabase. Bisa terasa lambat.
3. **No realtime** — user harus pull-to-refresh.
4. **No pagination** — list tiket/notifikasi load semua sekaligus. Akan lemot di 10k+ rows.
5. **No local cache** — kalau offline, app tidak menampilkan apa-apa.
6. **ID tiket berbasis timestamp** — relatif aman untuk demo, tetapi produksi tetap lebih baik memakai UUID.
7. **Tidak ada image preview** untuk attachment — harus download manual.

## 9.8 File Paling Penting untuk Direview (Kalau Penguji Punya Waktu Terbatas)

Baca file ini dalam urutan ini (mulai dari yang paling penting):

1. **`lib/main.dart`** — lihat setup app
2. **`lib/services/supabase_service.dart`** — lihat semua query
3. **`lib/core/router/app_router.dart`** — lihat routing
4. **`lib/presentation/providers/auth_provider.dart`** — lihat state management
5. **`lib/presentation/screens/tickets/ticket_detail_screen.dart`** — lihat screen paling kompleks
6. **`lib/data/models/ticket_model.dart`** — lihat model + parsing

---

**Selesai.** Laporan lengkap ada di folder `laporan/`. Index: [README.md](README.md).