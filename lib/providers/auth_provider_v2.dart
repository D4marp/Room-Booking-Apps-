import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/google_calendar_service.dart';
import '../utils/api_config.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _userModel;
  bool _isLoading = false;
  String? _errorMessage;
  String? _authToken;
  late GoogleSignIn _googleSignIn;
  late GoogleCalendarService _googleCalendarService;

  // Getters
  UserModel? get userModel => _userModel;
  UserModel? get currentUser => _userModel; // Alias for userModel
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _authToken != null && _userModel != null;
  String? get authToken => _authToken;
  bool get isAdmin => _userModel?.role == UserRole.admin;

  AuthProvider() {
    _initializeAuth();
    _googleSignIn = GoogleSignIn(
      scopes: [
        'profile',
        'email',
      ],
    );
    _googleCalendarService = GoogleCalendarService();
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
        
        try {
          // Use UserModel.fromJson to properly handle role conversion
          _userModel = UserModel.fromJson(response['user']);
          // Override name if provided
          _userModel = _userModel!.copyWith(name: name);
        } catch (e) {
          _errorMessage = 'Error processing user data: $e';
          _isLoading = false;
          notifyListeners();
          return false;
        }
        
        _isLoading = false;
        notifyListeners();
        return true;
      }
      throw 'Registration failed: No token received';
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
        
        try {
          // Use UserModel.fromJson to properly handle role conversion
          _userModel = UserModel.fromJson(response['user']);
        } catch (e) {
          _errorMessage = 'Error processing user data: $e';
          _isLoading = false;
          notifyListeners();
          return false;
        }
        
        _isLoading = false;
        notifyListeners();
        return true;
      }
      throw 'Login failed: No token received';
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

  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _errorMessage = 'Google sign in cancelled';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Send to backend for validation
      final response = await ApiService().post(
        '/auth/google',
        data: {
          'id_token': googleAuth.idToken,
          'access_token': googleAuth.accessToken,
          'email': googleUser.email,
          'name': googleUser.displayName,
        },
      );

      if (response['success'] == true) {
        _authToken = response['token'];
        _userModel = UserModel.fromJson(response['user']);
        ApiService().setAuthToken(_authToken!);

        // Connect to Google Calendar service
        await _googleCalendarService.signInWithGoogle(
          accessToken: googleAuth.accessToken ?? '',
          idToken: googleAuth.idToken,
          email: googleUser.email,
        );

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response['message'] ?? 'Sign in failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign out from Google
  Future<void> signOutGoogle() async {
    try {
      await _googleCalendarService.disconnect();
      await _googleSignIn.signOut();
      await signOut();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Convenience method alias for signOut
  Future<void> logout() => signOut();

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
