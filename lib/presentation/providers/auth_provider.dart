import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';
import '../../services/supabase_service.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  String? _errorMessage;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await SupabaseService().login(email, password);
      if (user == null) {
        _errorMessage = 'Email atau password salah / akun tidak aktif';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      // Coba tebak jenis error agar user bisa paham
      final msg = e.toString().toLowerCase();
      if (msg.contains('connect') ||
          msg.contains('timeout') ||
          msg.contains('network') ||
          msg.contains('socket') ||
          msg.contains('ioexception') ||
          msg.contains('exception')) {
        _errorMessage =
            'Tidak bisa sambung ke server. Pastikan internet nyala, lalu coba lagi.';
      } else if (msg.contains('policy') ||
          msg.contains('permission') ||
          msg.contains('403') ||
          msg.contains('Authorization')) {
        _errorMessage =
            'Akses ditolak server. Hubungi admin untuk konfigurasi RLS.';
      } else if (msg.contains('401') || msg.contains('unauthorized')) {
        _errorMessage = 'Email atau password salah.';
      } else {
        _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
      }
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final service  = SupabaseService();
      final allUsers = await service.getAllUsers();

      if (allUsers.any((u) => u.email == email)) {
        _errorMessage = 'Email sudah terdaftar';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final newUser = UserModel(
        id:        DateTime.now().millisecondsSinceEpoch.toString(),
        name:      name,
        email:     email,
        password:  password,
        role:      UserRole.user,
        createdAt: DateTime.now(),
      );
      await service.createUser(newUser);
      _currentUser = newUser;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal mendaftar, coba lagi';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    notifyListeners();
    final allUsers = await SupabaseService().getAllUsers();
    final exists   = allUsers.any((u) => u.email == email);
    _isLoading = false;
    notifyListeners();
    return exists;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}