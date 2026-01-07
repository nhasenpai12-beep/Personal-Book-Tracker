# Android Build & Test Guide

## Prerequisites

### 1. Install Android SDK
If you don't have Android Studio:
```bash
flutter doctor
```
This will show you if Android toolchain is installed. If not:
- Install Android Studio from: https://developer.android.com/studio
- During installation, include Android SDK and Android SDK Platform-Tools

### 2. Setup Android Emulator (Recommended)
Using Android Studio:
1. Open Android Studio
2. Go to **Tools > Device Manager**
3. Click **Create Device**
4. Select a phone (e.g., Pixel 5)
5. Download and select a system image (API 33 recommended)
6. Finish and start the emulator

### 3. Or Connect Physical Android Device
1. Enable **Developer Options** on your Android phone:
   - Go to Settings > About Phone
   - Tap "Build Number" 7 times
2. Enable **USB Debugging**:
   - Settings > Developer Options > USB Debugging
3. Connect phone via USB cable
4. Accept "Allow USB Debugging" prompt on phone

## Building & Running the App

### 1. Check Available Devices
```bash
flutter devices
```
You should see:
- Android emulator(s)
- Connected physical Android device(s)

Example output:
```
Android SDK built for x86 (mobile) • emulator-5554 • android-x86    • Android 13 (API 33)
Pixel 5 (mobile)                   • 1234567890ABC • android-arm64  • Android 12 (API 31)
```

### 2. Build and Run on Android
```bash
# Run on first available Android device
flutter run

# Or specify device by ID
flutter run -d emulator-5554

# Build APK for distribution
flutter build apk --release

# Build App Bundle (for Play Store)
flutter build appbundle --release
```

### 3. Hot Reload During Development
Once the app is running:
- Press `r` in terminal for hot reload
- Press `R` for hot restart
- Press `q` to quit

## Testing the EPUB Reader

1. **Launch the app** on Android device/emulator
2. **Navigate to Library** - You should see 5 pre-loaded classic books:
   - Alice's Adventures in Wonderland
   - Pride and Prejudice
   - The Adventures of Sherlock Holmes
   - Dracula
   - Frankenstein

3. **Tap any book** to open the EPUB reader
4. **Test features**:
   - Page navigation (swipe/scroll)
   - Text selection
   - Translation popup (tap floating translate button)
   - Dark/Light theme toggle
   - Reading progress tracking

## Storage Permissions

The app requests storage permissions to:
- Read EPUB files from device
- Write reading progress data
- Cache book covers

On first launch, you may need to:
1. Grant **Storage** permission when prompted
2. If you added books via file picker, ensure permissions are granted

## Troubleshooting

### Issue: No Android devices found
**Solution:**
```bash
# Check connected devices
adb devices

# Restart adb server
adb kill-server
adb start-server
```

### Issue: Emulator won't start
**Solution:**
- Ensure Intel HAXM (or AMD equivalent) is installed
- Increase emulator RAM in Device Manager
- Try a different system image (x86 vs ARM)

### Issue: Build fails with Gradle errors
**Solution:**
```bash
# Clean build cache
flutter clean
flutter pub get

# Try building again
flutter run
```

### Issue: Books won't open
**Solution:**
- Check storage permissions are granted
- Verify EPUB files exist in app's documents directory
- Check logcat for errors:
```bash
adb logcat | grep Flutter
```

### Issue: App crashes on book open
**Solution:**
- Ensure minSdk is 21+ in `android/app/build.gradle.kts`
- Verify vocsy_epub_viewer is properly installed:
```bash
flutter pub get
flutter clean
flutter run
```

## Performance Optimization

For best performance on Android:

1. **Use Release Mode for testing**:
```bash
flutter run --release
```

2. **Enable ProGuard** (for smaller APK):
Add to `android/app/build.gradle.kts`:
```kotlin
buildTypes {
    release {
        minifyEnabled = true
        proguardFiles(getDefaultProguardFile("proguard-android.txt"), "proguard-rules.pro")
    }
}
```

3. **Monitor Performance**:
```bash
# Check app size
flutter build apk --analyze-size

# Profile performance
flutter run --profile
```

## Distribution

### Generate Signed APK

1. **Create keystore**:
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

2. **Configure signing** in `android/key.properties`:
```
storePassword=<password>
keyPassword=<password>
keyAlias=upload
storeFile=<path-to-keystore>/upload-keystore.jks
```

3. **Build signed APK**:
```bash
flutter build apk --release
```

APK location: `build/app/outputs/flutter-apk/app-release.apk`

## Next Steps

- Test translation feature with real text selection
- Add more books via file picker
- Customize theme settings
- Implement real translation API (currently using mock data)
- Add reading statistics and achievements
- Integrate spaced repetition for vocabulary learning

## Support

If you encounter issues:
1. Check Flutter version: `flutter --version`
2. Run: `flutter doctor -v`
3. Check logs: `adb logcat | grep Flutter`
4. Verify all dependencies: `flutter pub get`
