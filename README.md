# TaskPet - Gamified Todo App with Authentication

A Flutter-based productivity app that combines task management with virtual pet mechanics, now featuring comprehensive user authentication.

## Features

### 🔐 Authentication System
- **User Registration & Login**: Secure signup and signin with email/password
- **Password Recovery**: Forgot password functionality with email-based reset
- **JWT Authentication**: Token-based authentication with secure storage
- **Session Management**: Automatic login persistence and logout functionality
- **Form Validation**: Comprehensive client-side validation for all auth forms
- **Error Handling**: User-friendly error messages and loading states

### 📱 Core App Features
- **Task Management**: Create, edit, and organize your todos
- **Virtual Pet System**: Care for your pet by completing tasks
- **Gamification**: Earn rewards and achievements through productivity
- **Smart Reminders**: Stay on track with intelligent notifications
- **Cross-Platform**: Works on iOS, Android, and Web

## Authentication Setup

### Prerequisites
- Flutter SDK (>=3.9.2)
- Android Studio / VS Code with Flutter extensions
- Android SDK (for Android builds)
- Xcode (for iOS builds, macOS only)

### Dependencies
The authentication system uses the following packages:
```yaml
dependencies:
  # Authentication & Security
  http: ^1.1.0
  dio: ^5.3.2
  jwt_decoder: ^2.0.1
  crypto: ^3.0.3
  flutter_secure_storage: ^9.0.0
  email_validator: ^2.1.17
  
  # State Management
  provider: ^6.1.2
  
  # Core Flutter packages
  flutter:
    sdk: flutter
```

### Installation

1. **Clone the repository:**
```bash
git clone <repository-url>
cd todo_app
```

2. **Install dependencies:**
```bash
flutter pub get
```

3. **Configure platform-specific settings:**

#### Android Configuration
Add the following to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

#### iOS Configuration
Add the following to `ios/Runner/Info.plist`:
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

4. **Run the application:**
```bash
flutter run
```

## Authentication Usage

### Demo Credentials
For testing the authentication system, use these demo credentials:
- **Email:** `test@example.com`
- **Password:** `password123`

### Authentication Flow

#### 1. User Registration
```dart
// Example of signup process
final authProvider = Provider.of<AuthProvider>(context);
final success = await authProvider.signup(name, email, password);
if (success) {
  // Navigate to home screen
  Navigator.pushReplacementNamed(context, '/home');
}
```

#### 2. User Login
```dart
// Example of login process
final authProvider = Provider.of<AuthProvider>(context);
final success = await authProvider.login(email, password);
if (success) {
  // User is now authenticated
  Navigator.pushReplacementNamed(context, '/home');
}
```

#### 3. Password Reset
```dart
// Example of password reset
final authProvider = Provider.of<AuthProvider>(context);
final success = await authProvider.forgotPassword(email);
if (success) {
  // Reset email sent
}
```

#### 4. Logout
```dart
// Example of logout
final authProvider = Provider.of<AuthProvider>(context);
await authProvider.logout();
// User is now logged out and redirected to login screen
```

### Authentication Screens

1. **Login Screen** (`lib/screens/auth/login_screen.dart`)
   - Email and password fields with validation
   - "Forgot Password" link
   - Demo credentials display for testing

2. **Signup Screen** (`lib/screens/auth/signup_screen.dart`)
   - Full name, email, password, and confirm password fields
   - Terms of service acceptance
   - Comprehensive validation rules

3. **Forgot Password Screen** (`lib/screens/auth/forgot_password_screen.dart`)
   - Email input for password reset
   - Email sent confirmation state
   - Resend functionality

4. **Reset Password Screen** (`lib/screens/auth/reset_password_screen.dart`)
   - Token input from email
   - New password with confirmation
   - Password strength requirements

### State Management

The authentication system uses the Provider pattern with `AuthProvider`:

```dart
class AuthProvider extends ChangeNotifier {
  // User authentication state
  User? get user;
  bool get isAuthenticated;
  bool get isLoading;
  String? get errorMessage;
  
  // Authentication methods
  Future<bool> login(String email, String password);
  Future<bool> signup(String name, String email, String password);
  Future<bool> forgotPassword(String email);
  Future<bool> resetPassword(String token, String newPassword);
  Future<void> logout();
}
```

### Route Protection

Protected routes are automatically handled by the `AuthWrapper` widget:

```dart
// Wrap protected content with AuthWrapper
AuthWrapper(
  child: HomeScreen(),
)

// Or use AuthGuard for specific route protection
AuthGuard(
  child: ProtectedScreen(),
  requireAuth: true,
)
```

### Secure Storage

User credentials and tokens are stored securely using `flutter_secure_storage`:
- JWT tokens stored in platform keychain/keystore
- User data encrypted at rest
- Automatic token expiry handling

## API Integration

### Backend Endpoints
The authentication system is designed to work with these API endpoints:

```
POST /api/auth/signup     - User registration
POST /api/auth/login      - User authentication
POST /api/auth/logout     - User logout
POST /api/auth/forgot-password - Password reset request
POST /api/auth/reset-password  - Password reset with token
POST /api/auth/refresh-token   - JWT token refresh
```

### Mock Implementation
For development and testing, the app includes mock authentication:
- Simulated network delays
- Realistic validation errors
- Demo user accounts

### Real API Integration
To connect to a real backend:

1. Update the base URL in `lib/services/auth_service.dart`:
```dart
static const String _baseUrl = 'https://your-api-domain.com/api/auth';
```

2. Replace mock methods with real API calls:
```dart
// Change from:
final response = await _authService.loginMock(request);
// To:
final response = await _authService.login(request);
```

## Security Features

### Password Requirements
- Minimum 6 characters
- Must contain at least one letter
- Must contain at least one number
- Confirmation required during signup and password reset

### Token Security
- JWT tokens stored in secure storage
- Automatic token refresh
- Token expiry detection and handling
- Secure logout with token cleanup

### Input Validation
- Email format validation
- Password strength checking
- Real-time form validation
- Server-side error display

## Troubleshooting

### Common Issues

1. **Build Errors on Android:**
   - Ensure Android SDK Platform 35 is installed
   - Update Android SDK and build tools
   - Clean and rebuild: `flutter clean && flutter pub get`

2. **Secure Storage Issues:**
   - On Android: Ensure minimum SDK version is 18+
   - On iOS: Ensure deployment target is iOS 12.0+
   - Clear app data if storage becomes corrupted

3. **Network Issues:**
   - Check internet connectivity
   - Verify API endpoint accessibility
   - Configure network security config for Android

4. **Authentication Persistence:**
   - Clear secure storage if login state is inconsistent
   - Check for token expiry
   - Verify authentication provider initialization

### Debug Mode
To enable debug logging for authentication:
```dart
// In auth_service.dart
debugPrint('Authentication request: ${request.toJson()}');
debugPrint('Authentication response: ${response.data}');
```

## Development Notes

### Mock vs Real Authentication
The app is configured with mock authentication by default. To switch to real API:

1. Implement your backend API endpoints
2. Update the `AuthService` base URL
3. Replace mock method calls with real API calls
4. Configure proper error handling for your API response format

### Extending Authentication
To add additional authentication features:

1. **Social Login**: Add Google/Apple sign-in packages
2. **Biometric Auth**: Implement fingerprint/face ID login
3. **Two-Factor Auth**: Add TOTP/SMS verification
4. **Profile Management**: Extend user model and add profile screens

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/new-auth-feature`
3. Commit your changes: `git commit -m 'Add new auth feature'`
4. Push to the branch: `git push origin feature/new-auth-feature`
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For issues and questions:
1. Check the troubleshooting section above
2. Search existing GitHub issues
3. Create a new issue with detailed information
4. Include logs and device information for bugs
