import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../models/auth_models.dart';
import '../models/user_model.dart';
import 'google_auth_service.dart';

class AuthService {
  static const String _baseUrl = 'http://localhost:3000/api/auth';
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  
  late Dio _dio;
  final GoogleAuthService _googleAuthService = GoogleAuthService();
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  AuthService() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    // Add request interceptor to include auth token
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          // Token expired, clear storage
          await clearAuthData();
        }
        handler.next(error);
      },
    ));
  }

  // Token management
  Future<void> _saveToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  Future<void> _saveUser(User user) async {
    await _secureStorage.write(key: _userKey, value: jsonEncode(user.toJson()));
  }

  Future<User?> getUser() async {
    final userData = await _secureStorage.read(key: _userKey);
    if (userData != null) {
      return User.fromJson(jsonDecode(userData));
    }
    return null;
  }

  Future<void> clearAuthData() async {
    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: _userKey);
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    if (token == null) return false;
    
    try {
      // Check if token is expired
      return !JwtDecoder.isExpired(token);
    } catch (e) {
      return false;
    }
  }

  // Authentication methods
  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await _dio.post('/login', data: request.toJson());
      
      final authResponse = AuthResponse.fromJson(response.data);
      
      if (authResponse.success && authResponse.token != null) {
        await _saveToken(authResponse.token!);
        if (authResponse.user != null) {
          await _saveUser(authResponse.user!);
        }
      }
      
      return authResponse;
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  Future<AuthResponse> signup(SignupRequest request) async {
    try {
      final response = await _dio.post('/signup', data: request.toJson());
      
      final authResponse = AuthResponse.fromJson(response.data);
      
      if (authResponse.success && authResponse.token != null) {
        await _saveToken(authResponse.token!);
        if (authResponse.user != null) {
          await _saveUser(authResponse.user!);
        }
      }
      
      return authResponse;
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  Future<AuthResponse> forgotPassword(ForgotPasswordRequest request) async {
    try {
      final response = await _dio.post('/forgot-password', data: request.toJson());
      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  Future<AuthResponse> resetPassword(ResetPasswordRequest request) async {
    try {
      final response = await _dio.post('/reset-password', data: request.toJson());
      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  Future<AuthResponse> logout() async {
    try {
      await _dio.post('/logout');
    } catch (e) {
      // Continue with logout even if server request fails
    }
    
    // Sign out from Google as well
    await _googleAuthService.signOut();
    
    await clearAuthData();
    return AuthResponse(success: true, message: 'Logged out successfully');
  }

  // Google Sign-In methods
  Future<AuthResponse> signInWithGoogle() async {
    try {
      // Use mock Google sign-in for development
      final response = await _googleAuthService.mockGoogleSignIn();
      
      if (response.success && response.token != null) {
        await _saveToken(response.token!);
        if (response.user != null) {
          await _saveUser(response.user!);
        }
      }
      
      return response;
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'Google Sign-In failed: ${e.toString()}',
      );
    }
  }

  Future<AuthResponse?> silentGoogleSignIn() async {
    try {
      final response = await _googleAuthService.signInSilently();
      
      if (response != null && response.success && response.token != null) {
        await _saveToken(response.token!);
        if (response.user != null) {
          await _saveUser(response.user!);
        }
      }
      
      return response;
    } catch (e) {
      return null;
    }
  }

  Future<AuthResponse> refreshToken() async {
    try {
      final response = await _dio.post('/refresh-token');
      final authResponse = AuthResponse.fromJson(response.data);
      
      if (authResponse.success && authResponse.token != null) {
        await _saveToken(authResponse.token!);
        if (authResponse.user != null) {
          await _saveUser(authResponse.user!);
        }
      }
      
      return authResponse;
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'Token refresh failed: ${e.toString()}',
      );
    }
  }

  // Error handling
  AuthResponse _handleError(DioException error) {
    String message = 'An error occurred';
    Map<String, dynamic>? errors;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'Connection timeout. Please check your internet connection.';
        break;
      case DioExceptionType.connectionError:
        message = 'Unable to connect to server. Please check your internet connection.';
        break;
      case DioExceptionType.badResponse:
        if (error.response?.data != null) {
          try {
            final responseData = error.response!.data;
            message = responseData['message'] ?? 'Server error occurred';
            errors = responseData['errors'];
          } catch (e) {
            message = 'Server returned an error (${error.response?.statusCode})';
          }
        }
        break;
      default:
        message = 'An unexpected error occurred';
    }

    return AuthResponse(
      success: false,
      message: message,
      errors: errors,
    );
  }

  // Mock API for development (remove when backend is ready)
  Future<AuthResponse> _mockLogin(LoginRequest request) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    
    // Mock validation
    if (request.email.isEmpty || request.password.isEmpty) {
      return AuthResponse(
        success: false,
        message: 'Email and password are required',
        errors: {
          'email': request.email.isEmpty ? ['Email is required'] : null,
          'password': request.password.isEmpty ? ['Password is required'] : null,
        },
      );
    }

    if (request.email == 'test@example.com' && request.password == 'password123') {
      final user = User(
        id: '1',
        name: 'Test User',
        email: request.email,
        isEmailVerified: true,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      const token = 'mock_jwt_token_here';
      await _saveToken(token);
      await _saveUser(user);

      return AuthResponse(
        success: true,
        message: 'Login successful',
        token: token,
        user: user,
      );
    }

    return AuthResponse(
      success: false,
      message: 'Invalid email or password',
    );
  }

  Future<AuthResponse> _mockSignup(SignupRequest request) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    
    // Mock validation
    final errors = <String, List<String>>{};
    
    if (request.name.isEmpty) {
      errors['name'] = ['Name is required'];
    }
    if (request.email.isEmpty) {
      errors['email'] = ['Email is required'];
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(request.email)) {
      errors['email'] = ['Please enter a valid email address'];
    }
    if (request.password.isEmpty) {
      errors['password'] = ['Password is required'];
    } else if (request.password.length < 6) {
      errors['password'] = ['Password must be at least 6 characters long'];
    }

    if (errors.isNotEmpty) {
      return AuthResponse(
        success: false,
        message: 'Validation failed',
        errors: errors,
      );
    }

    // Check if email already exists (mock)
    if (request.email == 'existing@example.com') {
      return AuthResponse(
        success: false,
        message: 'Email already exists',
        errors: {
          'email': ['This email is already registered']
        },
      );
    }

    final user = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: request.name,
      email: request.email,
      isEmailVerified: false,
      createdAt: DateTime.now(),
    );

    const token = 'mock_jwt_token_here';
    await _saveToken(token);
    await _saveUser(user);

    return AuthResponse(
      success: true,
      message: 'Account created successfully',
      token: token,
      user: user,
    );
  }

  // Use mock methods during development
  Future<AuthResponse> loginMock(LoginRequest request) => _mockLogin(request);
  Future<AuthResponse> signupMock(SignupRequest request) => _mockSignup(request);
}