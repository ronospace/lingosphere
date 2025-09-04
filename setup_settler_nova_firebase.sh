#!/bin/bash

# Settler-Nova Firebase Integration Setup Script
# This script helps configure LingoSphere to use the Settler-Nova Firebase project

echo "🔥 Setting up LingoSphere with Settler-Nova Firebase Project"
echo "============================================================="

# Check if we're in the correct directory
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ Error: Please run this script from the project root directory"
    exit 1
fi

echo ""
echo "📋 Settler-Nova Firebase Setup Checklist:"
echo ""

# Check for existing configuration files
echo "1. 🤖 Android Configuration (google-services.json):"
if [ -f "android/app/google-services.json" ]; then
    echo "   ✅ Found existing google-services.json"
    
    # Check if it's for Settler-Nova project
    if grep -q "settler-nova" android/app/google-services.json; then
        echo "   ✅ Configuration is for Settler-Nova project"
    else
        echo "   ⚠️  Configuration may not be for Settler-Nova project"
        echo "   📝 Please verify the project_id is 'settler-nova'"
    fi
else
    echo "   ❌ Missing google-services.json"
    echo "   📝 Steps to get it:"
    echo "      1. Go to https://console.firebase.google.com/"
    echo "      2. Select 'Settler-Nova' project"
    echo "      3. Add Android app with package: com.lingosphere.lingosphere"
    echo "      4. Download google-services.json"
    echo "      5. Place it in: android/app/google-services.json"
fi

echo ""
echo "2. 🍎 iOS Configuration (GoogleService-Info.plist):"
if [ -f "ios/Runner/GoogleService-Info.plist" ]; then
    echo "   ✅ Found existing GoogleService-Info.plist"
    
    # Check if it's for the correct bundle ID
    if grep -q "com.lingosphere.lingosphere" ios/Runner/GoogleService-Info.plist; then
        echo "   ✅ Configuration has correct bundle ID"
    else
        echo "   ⚠️  Configuration may not have correct bundle ID"
        echo "   📝 Please verify BUNDLE_ID is 'com.lingosphere.lingosphere'"
    fi
else
    echo "   ❌ Missing GoogleService-Info.plist"
    echo "   📝 Steps to get it:"
    echo "      1. In the same Settler-Nova Firebase project"
    echo "      2. Add iOS app with bundle ID: com.lingosphere.lingosphere"
    echo "      3. Download GoogleService-Info.plist"
    echo "      4. Place it in: ios/Runner/GoogleService-Info.plist"
fi

echo ""
echo "3. 🔧 Firebase Services Setup:"
echo "   📝 Ensure these services are enabled in Settler-Nova project:"
echo "   - ✅ Authentication (Google, Anonymous)"
echo "   - ✅ Firestore Database"
echo "   - ✅ Analytics"
echo "   - ✅ Crashlytics"
echo "   - ✅ Cloud Storage"
echo "   - ✅ Remote Config"

echo ""
echo "4. 🛡️ Security Rules:"
echo "   📝 Update Firestore and Storage rules for LingoSphere data isolation"
echo "   📁 See SETTLER_NOVA_FIREBASE_SETUP.md for production-ready rules"

echo ""
echo "5. 🧪 Test Configuration:"
if [ -f "android/app/google-services.json" ]; then
    echo "   ✅ Ready to test Android integration"
    echo "   🚀 Run: flutter run -d emulator-5554"
else
    echo "   ⏳ Waiting for configuration files"
fi

echo ""
echo "📚 Quick Reference:"
echo "   - Project ID: settler-nova"
echo "   - Android Package: com.lingosphere.lingosphere"
echo "   - iOS Bundle ID: com.lingosphere.lingosphere"
echo "   - Firebase Console: https://console.firebase.google.com/"

echo ""
echo "🔗 Next Steps:"
echo "   1. Complete Firebase Console setup (add apps to Settler-Nova)"
echo "   2. Download and place configuration files"
echo "   3. Run this script again to verify setup"
echo "   4. Test the app with Firebase integration"

echo ""
if [ -f "android/app/google-services.json" ] && [ -f "ios/Runner/GoogleService-Info.plist" ]; then
    echo "🎉 Setup complete! Firebase integration is ready."
    echo "🚀 Test your app: flutter run -d emulator-5554"
else
    echo "⏳ Setup in progress. Complete the missing configuration files above."
fi
