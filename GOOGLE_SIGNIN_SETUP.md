# Google Sign-In Setup Guide

## 🔥 Firebase Project Setup

### Step 1: Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project" or select existing project
3. Follow the setup wizard
4. Enable Google Analytics (optional)

### Step 2: Enable Authentication
1. In Firebase Console, go to **Authentication**
2. Click **Get started**
3. Go to **Sign-in method** tab
4. Enable **Google** provider
5. Set project support email

## 📱 Android Configuration

### Step 1: Add Android App
1. In Firebase Console, click **Add app** → Android
2. **Package name**: `com.taskpet.app` (matches android/app/build.gradle.kts)
3. **App nickname**: TaskPet (optional)
4. Leave **Debug signing certificate SHA-1** empty for now

### Step 2: Download google-services.json
1. Download `google-services.json` from Firebase Console
2. Place it in `android/app/` directory
3. ⚠️ **IMPORTANT**: This file contains sensitive data - add to .gitignore

### Step 3: Get SHA-1 Fingerprints

#### For Debug Build:
```bash
cd android
./gradlew signingReport
```
Look for the SHA1 under `Variant: debug` and `Config: debug`

#### Alternative method (using keytool):
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

#### For Release Build:
```bash
keytool -list -v -keystore path/to/your/release-keystore.jks -alias your-key-alias
```

### Step 4: Add SHA-1 to Firebase
1. Go to Firebase Console → Project Settings
2. Add your SHA-1 fingerprints under "Your apps" → Android app
3. Download updated `google-services.json`

### Step 5: Get Web Client ID
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your Firebase project
3. Navigate to **APIs & Services** → **Credentials**
4. Find "Web client (auto created by Google Service)" 
5. Copy the **Client ID** (ends with `.apps.googleusercontent.com`)
6. Update in `lib/services/google_auth_service.dart`:
   ```dart
   static const String _webClientId = 'YOUR_CLIENT_ID.apps.googleusercontent.com';
   ```

## iOS Setup

### Step 1: Add iOS App to Firebase
1. Add iOS app to your Firebase project
2. Use bundle ID from `ios/Runner/Info.plist` (e.g., `com.example.taskpet`)
3. Download `GoogleService-Info.plist`

### Step 2: Configure iOS
1. Place `GoogleService-Info.plist` in `ios/Runner/` directory
2. Add it to Xcode project (open `ios/Runner.xcworkspace`)
3. Update `ios/Runner/Info.plist` with URL scheme from `GoogleService-Info.plist`

### Step 3: URL Scheme
Add this to `ios/Runner/Info.plist`:
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>BUNDLE_ID</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>REVERSED_CLIENT_ID</string>
        </array>
    </dict>
</array>
```

Replace `REVERSED_CLIENT_ID` with value from `GoogleService-Info.plist`

## Web Setup

### Configure Web Client ID
1. Get web client ID from Google Cloud Console
2. Update `GoogleAuthService` constructor with your web client ID
3. Add your domain to authorized domains in Firebase Authentication

## Testing

### Test Google Sign-In
1. Run the app on a physical device (Google Sign-In doesn't work on emulators without Google Play Services)
2. Tap "Continue with Google" button
3. Complete Google sign-in flow
4. Verify user data is properly saved and authenticated

### Mock Testing
- The app includes mock Google Sign-In for development
- Switch to real implementation by updating service calls in AuthProvider

## Troubleshooting

### Common Issues:
1. **SHA-1 fingerprint mismatch**: Regenerate and update in Firebase
2. **Network error**: Check internet connectivity and Firebase configuration
3. **Sign-in cancelled**: User cancelled the flow (expected behavior)
4. **Invalid client**: Verify google-services.json and bundle IDs match

### Debug Steps:
1. Check Firebase console for project configuration
2. Verify SHA-1 fingerprints are correct
3. Ensure google-services.json is in correct location
4. Check device has Google Play Services (Android)
5. Test on physical device, not emulator