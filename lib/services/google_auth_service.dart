import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/auth_models.dart';

class GoogleAuthService {
  // Temporary flag to use mock for testing (set to false once Firebase is configured)
  static const bool _useMockForTesting = true;
  // Web Client ID from Firebase Console - TaskPet Project
  // Project: taskpet---gamified-todo-df1b8
  static const String _webClientId = '278853249268-kj80klonnjvg7rq46nv465ki61drqutf.apps.googleusercontent.com';
  
  late GoogleSignIn _googleSignIn;
  
  GoogleAuthService() {
    _googleSignIn = GoogleSignIn(
      scopes: [
        'email',
        'profile',
        'openid',
      ],
      // Web client ID is required for web platform
      clientId: kIsWeb ? _webClientId : null,
      // Add server client ID for web
      serverClientId: kIsWeb ? _webClientId : null,
    );
  }

  /// Sign in with Google
  Future<AuthResponse> signInWithGoogle() async {
    // Temporary mock while Firebase is being configured
    if (_useMockForTesting) {
      debugPrint('🧪 Using mock Google Sign-In (Firebase not configured yet)');
      return mockGoogleSignIn();
    }
    
    try {
      debugPrint('🚀 Starting Google Sign-In...');
      debugPrint('Platform: ${kIsWeb ? "Web" : "Mobile"}');
      debugPrint('Client ID configured: ${_webClientId.isNotEmpty}');
      
      // For web, try a simpler approach first
      if (kIsWeb) {
        debugPrint('Using web-optimized sign-in flow...');
      }
      
      // Clear any previous sign-in state
      await _googleSignIn.signOut();
      
      debugPrint('Triggering Google Sign-In flow...');
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      
      if (account == null) {
        debugPrint('❌ Google Sign-In was cancelled or failed');
        return AuthResponse(
          success: false,
          message: 'Google Sign-In was cancelled by user',
        );
      }

      // Get authentication details
      final GoogleSignInAuthentication googleAuth = await account.authentication;
      
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        return AuthResponse(
          success: false,
          message: 'Failed to get Google authentication tokens',
        );
      }

      // Create user object from Google account data
      final user = User(
        id: account.id,
        name: account.displayName ?? 'Google User',
        email: account.email,
        isEmailVerified: true, // Google emails are always verified
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      debugPrint('Google Sign-In successful for: ${account.email}');
      
      return AuthResponse(
        success: true,
        message: 'Google Sign-In successful',
        token: googleAuth.idToken, // Use Google ID token as auth token
        user: user,
      );
      
    } catch (error) {
      debugPrint('Google Sign-In error: $error');
      
      String errorMessage = 'Google Sign-In failed';
      
      if (error.toString().contains('network_error')) {
        errorMessage = 'Network error. Please check your internet connection.';
      } else if (error.toString().contains('sign_in_canceled')) {
        errorMessage = 'Google Sign-In was cancelled';
      } else if (error.toString().contains('sign_in_failed')) {
        errorMessage = 'Google Sign-In failed. Please try again.';
      }
      
      return AuthResponse(
        success: false,
        message: errorMessage,
      );
    }
  }

  /// Sign out from Google
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      debugPrint('Google Sign-Out successful');
    } catch (error) {
      debugPrint('Google Sign-Out error: $error');
      // Continue with sign out even if Google sign out fails
    }
  }

  /// Disconnect from Google (revoke access)
  Future<void> disconnect() async {
    try {
      await _googleSignIn.disconnect();
      debugPrint('Google disconnect successful');
    } catch (error) {
      debugPrint('Google disconnect error: $error');
    }
  }

  /// Check if user is currently signed in to Google
  Future<bool> isSignedIn() async {
    try {
      return await _googleSignIn.isSignedIn();
    } catch (error) {
      debugPrint('Error checking Google sign-in status: $error');
      return false;
    }
  }

  /// Get current Google user if signed in
  GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;

  /// Silent sign-in (if user previously signed in)
  Future<AuthResponse?> signInSilently() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signInSilently();
      
      if (account == null) {
        return null; // No previous sign-in found
      }

      final GoogleSignInAuthentication googleAuth = await account.authentication;
      
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        return null;
      }

      final user = User(
        id: account.id,
        name: account.displayName ?? 'Google User',
        email: account.email,
        isEmailVerified: true,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      debugPrint('Google silent sign-in successful for: ${account.email}');
      
      return AuthResponse(
        success: true,
        message: 'Google silent sign-in successful',
        token: googleAuth.idToken,
        user: user,
      );
      
    } catch (error) {
      debugPrint('Google silent sign-in error: $error');
      return null;
    }
  }

  /// Mock Google Sign-In for development/testing
  Future<AuthResponse> mockGoogleSignIn() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    final user = User(
      id: 'google_${DateTime.now().millisecondsSinceEpoch}',
      name: 'John Doe',
      email: 'john.doe@gmail.com',
      isEmailVerified: true,
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
    );

    return AuthResponse(
      success: true,
      message: 'Mock Google Sign-In successful',
      token: 'mock_google_jwt_token',
      user: user,
    );
  }
}