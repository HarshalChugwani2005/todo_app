import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/auth_models.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? _user;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  User? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Initialize authentication state
  Future<void> initAuth() async {
    _setLoading(true);
    
    try {
      _isAuthenticated = await _authService.isAuthenticated();
      if (_isAuthenticated) {
        _user = await _authService.getUser();
      } else {
        // Try silent Google sign-in
        final googleResponse = await _authService.silentGoogleSignIn();
        if (googleResponse != null && googleResponse.success) {
          _user = googleResponse.user;
          _isAuthenticated = true;
        }
      }
    } catch (e) {
      _isAuthenticated = false;
      _user = null;
    }
    
    _setLoading(false);
  }

  // Login
  Future<bool> login(String email, String password) async {
    _clearError();
    _setLoading(true);

    try {
      final request = LoginRequest(email: email, password: password);
      
      // Use mock login for development
      final response = await _authService.loginMock(request);
      
      if (response.success) {
        _user = response.user;
        _isAuthenticated = true;
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _setError(response.message ?? 'Login failed');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('An unexpected error occurred during login');
      _setLoading(false);
      return false;
    }
  }

  // Signup
  Future<bool> signup(String name, String email, String password) async {
    _clearError();
    _setLoading(true);

    try {
      final request = SignupRequest(
        name: name,
        email: email,
        password: password,
      );
      
      // Use mock signup for development
      final response = await _authService.signupMock(request);
      
      if (response.success) {
        _user = response.user;
        _isAuthenticated = true;
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _setError(response.message ?? 'Signup failed');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('An unexpected error occurred during signup');
      _setLoading(false);
      return false;
    }
  }

  // Forgot Password
  Future<bool> forgotPassword(String email) async {
    _clearError();
    _setLoading(true);

    try {
      final request = ForgotPasswordRequest(email: email);
      final response = await _authService.forgotPassword(request);
      
      _setLoading(false);
      
      if (response.success) {
        return true;
      } else {
        _setError(response.message ?? 'Failed to send reset email');
        return false;
      }
    } catch (e) {
      _setError('An unexpected error occurred');
      _setLoading(false);
      return false;
    }
  }

  // Reset Password
  Future<bool> resetPassword(String token, String newPassword) async {
    _clearError();
    _setLoading(true);

    try {
      final request = ResetPasswordRequest(
        token: token,
        newPassword: newPassword,
      );
      final response = await _authService.resetPassword(request);
      
      _setLoading(false);
      
      if (response.success) {
        return true;
      } else {
        _setError(response.message ?? 'Failed to reset password');
        return false;
      }
    } catch (e) {
      _setError('An unexpected error occurred');
      _setLoading(false);
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    _setLoading(true);
    
    try {
      await _authService.logout();
    } catch (e) {
      // Continue with logout even if server request fails
    }
    
    _user = null;
    _isAuthenticated = false;
    _clearError();
    _setLoading(false);
    notifyListeners();
  }

  // Refresh token
  Future<bool> refreshToken() async {
    try {
      final response = await _authService.refreshToken();
      
      if (response.success) {
        _user = response.user ?? _user;
        _isAuthenticated = true;
        notifyListeners();
        return true;
      } else {
        await logout();
        return false;
      }
    } catch (e) {
      await logout();
      return false;
    }
  }

  // Update user profile
  void updateUser(User updatedUser) {
    _user = updatedUser;
    notifyListeners();
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Google Sign-In
  Future<bool> signInWithGoogle() async {
    _clearError();
    _setLoading(true);

    try {
      final response = await _authService.signInWithGoogle();
      
      if (response.success) {
        _user = response.user;
        _isAuthenticated = true;
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _setError(response.message ?? 'Google Sign-In failed');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('An unexpected error occurred during Google Sign-In');
      _setLoading(false);
      return false;
    }
  }

  // Clear error message (call this when user starts typing or navigates)
  void clearError() {
    _clearError();
  }
}