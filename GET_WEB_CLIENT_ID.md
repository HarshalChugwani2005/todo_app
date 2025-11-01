# 🔑 Get Your Web Client ID

## Quick Steps to Complete Google Sign-In Setup

### 1. Get Web Client ID

#### Option A: From Firebase Console
1. Go to [Firebase Console](https://console.firebase.google.com/project/taskpet---gamified-todo-app)
2. Click **Project Settings** (gear icon)
3. Scroll to **Your apps** section
4. Click on your **Web app**
5. Find **Web client ID** - it looks like: `278522225369-abcdef123456.apps.googleusercontent.com`

#### Option B: From Google Cloud Console  
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select project: **taskpet---gamified-todo-app**
3. Navigate to **APIs & Services** → **Credentials**
4. Look for "Web client (auto created by Google Service)"
5. Copy the **Client ID**

### 2. Update the Code

Replace this line in `lib/services/google_auth_service.dart` (line 9):

**Current:**
```dart
static const String _webClientId = '278522225369-your-web-client-id.apps.googleusercontent.com';
```

**Replace with your actual client ID:**
```dart
static const String _webClientId = '278522225369-YOUR_ACTUAL_CLIENT_ID.apps.googleusercontent.com';
```

### 3. Test Google Sign-In

```bash
# Test on web (works immediately)
flutter run -d chrome

# Test on mobile (requires additional setup)
flutter run
```

## Your Firebase Config Summary

```javascript
// Your Firebase Project Details
Project ID: taskpet---gamified-todo-app
API Key: AIzaSyD1K9yjCfL7Q-vVLTPkwGuKlNHuq6NnCmg
App ID: 1:278522225369:web:261a388406aa37047fd4c8
Auth Domain: taskpet---gamified-todo-app.firebaseapp.com
```

## Next Steps After Getting Client ID

1. ✅ Update web client ID in GoogleAuthService
2. 🔧 Enable Google Authentication in Firebase Console
3. 📱 Add Android/iOS apps in Firebase Console  
4. 🔄 Download real config files (google-services.json, GoogleService-Info.plist)
5. 🧪 Test on device

## Quick Test

Once you update the client ID, you can test Google Sign-In on web immediately:

```bash
cd "c:\Users\harsh\To do list flutter app\todo_app"
flutter run -d chrome
```

Click "Continue with Google" and the sign-in should work! 🚀