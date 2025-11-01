# 🚀 Firebase Setup Completion Guide - TaskPet

## ✅ What's Already Done
Your Firebase credentials have been integrated into the app:
- **Project ID**: taskpet---gamified-todo-app
- **API Key**: AIzaSyD1K9yjCfL7Q-vVLTPkwGuKlNHuq6NnCmg
- **App ID**: 1:278522225369:web:261a388406aa37047fd4c8
- Web configuration files created
- Android and iOS configuration templates ready

## 🔧 Next Steps Required

### 1. Complete Firebase Console Setup

#### Enable Authentication:
1. Go to [Firebase Console](https://console.firebase.google.com/project/taskpet---gamified-todo-app)
2. Navigate to **Authentication** → **Sign-in method**
3. Enable **Google** provider
4. Set project support email

#### Add Android App:
1. Click **Add app** → **Android**
2. **Package name**: `com.example.todo_app`
3. Download the real `google-services.json`
4. Replace the template file at `android/app/google-services.json`

#### Add iOS App:
1. Click **Add app** → **iOS**
2. **Bundle ID**: `com.example.todoApp` 
3. Download the real `GoogleService-Info.plist`
4. Replace the template file at `ios/Runner/GoogleService-Info.plist`

### 2. Update Client IDs

The configuration files currently have placeholder values marked with `xxxxxx`. You need to:

#### Get the actual client IDs from Firebase:
1. Go to **Project Settings** → **General** → **Your apps**
2. For each app (Web, Android, iOS), note the client IDs

#### Update these files with real client IDs:
- `lib/services/google_auth_service.dart` (line 4): Replace `278522225369-xxxxxx.apps.googleusercontent.com`
- `android/app/google-services.json`: Replace all `xxxxxx` placeholders
- `ios/Runner/GoogleService-Info.plist`: Replace `xxxxxx` placeholders
- `ios/Runner/Info.plist`: Replace `278522225369-xxxxxx`

### 3. Android SHA-1 Setup

For Google Sign-In to work on Android, you need to add SHA-1 fingerprints:

```powershell
# Navigate to android directory
cd "c:\Users\harsh\To do list flutter app\todo_app\android"

# Get debug SHA-1
.\gradlew signingReport
```

Look for the SHA1 under "Variant: debug" and add it to Firebase Console → Project Settings → Your apps → Android app

### 4. Test the Integration

After completing the setup:

```powershell
# Run on web (Google Sign-In works immediately)
flutter run -d chrome

# Run on Android device (requires SHA-1 setup)
flutter run

# Run on iOS device (requires Xcode configuration)
flutter run -d ios
```

## 🎯 Quick Verification Checklist

- [ ] Authentication enabled in Firebase Console
- [ ] Android app added with correct package name
- [ ] iOS app added with correct bundle ID  
- [ ] Real `google-services.json` downloaded and placed
- [ ] Real `GoogleService-Info.plist` downloaded and placed
- [ ] All `xxxxxx` placeholders replaced with actual client IDs
- [ ] SHA-1 fingerprint added for Android
- [ ] Google Sign-In tested on device

## 🔍 Files That Need Real Data

1. **android/app/google-services.json** - Replace entire file with Firebase download
2. **ios/Runner/GoogleService-Info.plist** - Replace entire file with Firebase download  
3. **lib/services/google_auth_service.dart** - Line 4: Update web client ID
4. **ios/Runner/Info.plist** - Line 50: Update REVERSED_CLIENT_ID

Once you complete these steps, Google Sign-In will be fully functional across all platforms!

## 📞 Need Help?
If you encounter any issues:
1. Check Firebase Console for project configuration
2. Verify package names match between app and Firebase
3. Ensure SHA-1 is correctly added for Android
4. Test on physical device (not emulator) first