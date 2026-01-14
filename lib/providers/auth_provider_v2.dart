import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../utils/api_config.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _userModel;
  bool _isLoading = false;
  String? _errorMessage;
  String? _authToken;

  // Getters
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _authToken != null && _userModel != null;
  String? get authToken => _authToken;
  bool get isAdmin => _userModel?.role == 'admin';

  AuthProvider() {
    _initializeAuth();
  }

  // Initialize auth
  void _initializeAuth() async {
    // Check if token exists in storage
    // TODO: Implement persistent storage for token
  }

  // Sign up with email and password
  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService().post(
        ApiConfig.registerEndpoint,
        data: {
          'email': email,
          'password': password,
          'name': name,
        },
      );

      if (response['token'] != null) {
        _authToken = response['token'];
        ApiService().setAuthToken(_authToken!);
        _userModel = UserModel(
          id: response['user']['id'] ?? '',
          email: email,
          name: name,
          role: response['user']['role'] ?? 'user',
          createdAt: DateTime.now(),
        );
        _isLoading = false;
        notifyListeners();
        return true;
      }
      throw 'Registration failed';
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign in with email and password
  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService().post(
        ApiConfig.loginEndpoint,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response['token'] != null) {
        _authToken = response['token'];
        ApiService().setAuthToken(_authToken!);
        _userModel = UserModel(
          id: response['user']['id'] ?? '',
          email: response['user']['email'] ?? '',
          name: response['user']['name'] ?? '',
          role: response['user']['role'] ?? 'user',
          createdAt: DateTime.parse(response['user']['createdAt'] ?? DateTime.now().toString()),
        );
        _isLoading = false;
        notifyListeners();
        return true;
      }
      throw 'Login failed';
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Google Sign In
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: Implement Google Sign In flow
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Microsoft Sign In
  Future<bool> signInWithMicrosoft() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: Implement Microsoft Sign In flow
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    _authToken = null;
    _userModel = null;
    ApiService().clearAuthToken();
    notifyListeners();
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
