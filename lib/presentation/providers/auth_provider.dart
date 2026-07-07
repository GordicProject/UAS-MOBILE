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
        _errorMessage = 'Email atau password salah';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan, coba lagi';
      _isLoading = false;
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