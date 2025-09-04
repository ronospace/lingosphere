# LingoSphere Firebase Setup using Settler-Nova

## Firebase Project Configuration

Since we're using the existing **Settler-Nova** Firebase project, we need to:
1. Add LingoSphere as a new app in the Settler-Nova project
2. Configure the Android and iOS apps with the correct package/bundle IDs
3. Download the new configuration files

## Step 1: Add LingoSphere Android App to Settler-Nova

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select the **Settler-Nova** project
3. Click the "Add app" button and select Android (🤖)
4. Enter the following details:
   - **Android package name**: `com.lingosphere.lingosphere`
   - **App nickname**: LingoSphere Android
   - **Debug signing certificate SHA-1**: (Leave blank for now)
5. Click "Register app"
6. Download the `google-services.json` file
7. Place it in: `android/app/google-services.json`

## Step 2: Add LingoSphere iOS App to Settler-Nova

1. In the same Firebase project, click "Add app" and select iOS (🍎)
2. Enter the following details:
   - **iOS bundle ID**: `com.lingosphere.lingosphere`
   - **App nickname**: LingoSphere iOS
3. Click "Register app"
4. Download the `GoogleService-Info.plist` file
5. Place it in: `ios/Runner/GoogleService-Info.plist`

## Step 3: Firebase Services Configuration

Ensure the following services are enabled in your Settler-Nova Firebase project:

### Required Services:
- ✅ **Authentication**: Enable Google Sign-In and Anonymous Authentication
- ✅ **Firestore Database**: Create database (production mode recommended)
- ✅ **Analytics**: Should be enabled by default
- ✅ **Crashlytics**: Enable for crash reporting
- ✅ **Cloud Storage**: Enable for file uploads
- ✅ **Remote Config**: Enable for app configuration

### Optional Services:
- ⚪ **Cloud Functions**: For server-side logic
- ⚪ **Cloud Messaging**: For push notifications
- ⚪ **Performance Monitoring**: For performance analytics

## Step 4: Security Rules Setup

### Firestore Rules (Production-Ready)
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Translation history - users can only access their own
    match /translations/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Public language data (read-only)
    match /languages/{document=**} {
      allow read: if true;
    }
    
    // App configuration (read-only)
    match /config/{document=**} {
      allow read: if true;
    }
  }
}
```

### Storage Rules (Production-Ready)
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Users can only access their own files
    match /users/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // OCR images - temporary storage (24 hours)
    match /ocr-temp/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null 
        && request.auth.uid == userId
        && request.time < resource.timeCreated + duration.value(24 * 60 * 60 * 1000); // 24 hours
    }
  }
}
```

## Step 5: Project Configuration Details

Your Firebase project will have these details:
- **Project ID**: settler-nova (existing project)
- **Project Name**: Settler-Nova
- **Apps**: 
  - LingoSphere Android: `com.lingosphere.lingosphere`
  - LingoSphere iOS: `com.lingosphere.lingosphere`

## Step 6: Environment Configuration

After downloading the configuration files, your project structure should look like:

```
lingosphere/
├── android/
│   └── app/
│       └── google-services.json        # ← New file from Firebase
├── ios/
│   └── Runner/
│       └── GoogleService-Info.plist    # ← New file from Firebase
└── ...
```

## Step 7: Verification Steps

1. **Download Configuration Files**: Get both Android and iOS config files
2. **Place Files Correctly**: Follow the directory structure above
3. **Run Configuration Script**: `./configure_firebase.sh`
4. **Test Integration**: `flutter run -d emulator-5554`
5. **Verify Firebase Connection**: Check logs for successful initialization

## Important Notes

- **Reuse Existing Services**: The Settler-Nova project's existing Firestore, Auth, and other services will be shared
- **Data Isolation**: Use proper security rules to isolate LingoSphere data
- **App Identification**: Each app (Android/iOS) will have unique identifiers within the same project
- **Shared Analytics**: Analytics data will be combined but can be filtered by app

## Next Steps After Configuration

1. **Test Firebase Authentication**: Verify Google Sign-In works
2. **Test Firestore Database**: Verify data read/write operations
3. **Test Analytics**: Check event tracking in Firebase console
4. **Test Crashlytics**: Verify crash reporting functionality
5. **Configure Remote Config**: Set up app configuration parameters

This setup allows LingoSphere to leverage the existing Settler-Nova Firebase infrastructure while maintaining proper app separation and security.
