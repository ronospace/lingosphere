#!/bin/bash

# Firebase Configuration Script for LingoSphere
# Run this script after downloading your Firebase configuration files

echo "🔥 LingoSphere Firebase Configuration Setup"
echo "=============================================="

# Check if we're in the correct directory
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ Error: Please run this script from the project root directory"
    exit 1
fi

# Function to check if file exists
check_file() {
    if [ -f "$1" ]; then
        echo "✅ Found: $1"
        return 0
    else
        echo "❌ Missing: $1"
        return 1
    fi
}

echo ""
echo "📋 Checking Firebase configuration files..."

# Check Android configuration
echo ""
echo "🤖 Android Configuration:"
if check_file "android/app/google-services.json"; then
    echo "   Android Firebase configuration is ready!"
else
    echo "   📝 Please download google-services.json from Firebase Console"
    echo "   📁 Place it in: android/app/google-services.json"
fi

# Check iOS configuration
echo ""
echo "🍎 iOS Configuration:"
if check_file "ios/Runner/GoogleService-Info.plist"; then
    echo "   iOS Firebase configuration is ready!"
else
    echo "   📝 Please download GoogleService-Info.plist from Firebase Console"
    echo "   📁 Place it in: ios/Runner/GoogleService-Info.plist"
fi

if check_file "ios/firebase_app_id_file.json"; then
    echo "   iOS App ID file is ready!"
else
    echo "   📝 iOS App ID file may be needed for some services"
    echo "   📁 Place it in: ios/firebase_app_id_file.json"
fi

# Check if templates exist and offer to remove them
echo ""
echo "🧹 Template Cleanup:"
if [ -f "android/app/google-services.json.template" ]; then
    echo "   Template files found. Remove them? (y/n)"
    read -p "   > " remove_templates
    if [ "$remove_templates" = "y" ] || [ "$remove_templates" = "Y" ]; then
        rm -f android/app/google-services.json.template
        rm -f ios/firebase_app_id_file.json.template
        echo "   ✅ Template files removed"
    fi
fi

# Test Firebase connection
echo ""
echo "🧪 Testing Firebase Configuration..."
echo "   Run the following command to test Firebase integration:"
echo "   flutter run -d emulator-5554"

echo ""
echo "📚 Next Steps:"
echo "1. Ensure all Firebase services are enabled in Firebase Console:"
echo "   - Authentication (Google, Anonymous)"
echo "   - Firestore Database"
echo "   - Analytics"
echo "   - Crashlytics"
echo "   - Cloud Storage"
echo "   - Remote Config"
echo ""
echo "2. Configure security rules for Firestore and Storage"
echo "3. Test the app with Firebase integration"
echo ""
echo "🎉 Firebase setup complete! You can now run your app."
