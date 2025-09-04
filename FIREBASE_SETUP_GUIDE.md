# Firebase Setup Guide for LingoSphere

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project" or "Add project"
3. Enter project name: **LingoSphere**
4. Choose to enable Google Analytics (recommended)
5. Select or create Google Analytics account
6. Click "Create project"

## Step 2: Configure Android App

1. In the Firebase console, click "Add app" and select Android
2. Enter the following details:
   - **Android package name**: `com.lingosphere.lingosphere`
   - **App nickname (optional)**: LingoSphere Android
   - **Debug signing certificate SHA-1**: Leave blank for now (optional for development)
3. Click "Register app"
4. Download the `google-services.json` file
5. Place it in: `android/app/google-services.json`

## Step 3: Configure iOS App (for future)

1. In the Firebase console, click "Add app" and select iOS
2. Enter the following details:
   - **iOS bundle ID**: `com.lingosphere.lingosphere`
   - **App nickname (optional)**: LingoSphere iOS
3. Click "Register app"
4. Download the `GoogleService-Info.plist` file
5. Place it in: `ios/Runner/GoogleService-Info.plist`

## Step 4: Enable Firebase Services

In the Firebase console, enable the following services:

### Authentication
1. Go to Authentication > Sign-in method
2. Enable Google Sign-In (recommended)
3. Enable Anonymous Sign-In (for offline users)
4. Configure other providers as needed

### Firestore Database
1. Go to Firestore Database
2. Create database in production mode (or test mode for development)
3. Choose location (us-central1 recommended)

### Analytics
1. Go to Analytics (should be auto-enabled)
2. Configure conversion events if needed

### Crashlytics
1. Go to Crashlytics
2. Follow setup instructions for crash reporting

### Cloud Storage
1. Go to Storage
2. Get started with default settings
3. Configure security rules as needed

### Remote Config
1. Go to Remote Config
2. Create initial configuration parameters

## Step 5: Get Configuration Files

After setting up, you'll need:
1. `google-services.json` (Android)
2. `GoogleService-Info.plist` (iOS)
3. `firebase_app_id_file.json` (for some services)

## Step 6: Project Configuration

The following Firebase project details will be needed:
- **Project ID**: lingosphere-[generated-suffix]
- **Web API Key**: (found in Project Settings > General)
- **App ID**: (found in Project Settings > General > Your apps)

## Security Rules Examples

### Firestore Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow authenticated users to read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Allow authenticated users to read/write translations
    match /translations/{translationId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### Storage Rules
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /users/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Environment Variables (for CI/CD)

Create these environment variables for deployment:
- `FIREBASE_PROJECT_ID`: Your project ID
- `FIREBASE_WEB_API_KEY`: Your web API key
- `FIREBASE_ANDROID_APP_ID`: Your Android app ID
- `FIREBASE_IOS_APP_ID`: Your iOS app ID (when created)

## Next Steps After Firebase Setup

1. Download the configuration files
2. Place them in the correct locations
3. Update the app's Firebase configuration
4. Test Firebase integration
5. Configure production settings
