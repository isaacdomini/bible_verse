# Bible Verse App

A Flutter app for iOS, Android, and web that listens to your voice and displays Bible verses when you say a reference. The app features voice recognition, Bible verse lookup, and casting capabilities.

## Features

- 🎤 **Voice Recognition**: Say any Bible verse reference and see it displayed
- 📱 **Cross-Platform**: Works on iOS, Android, and web
- 📺 **Casting Support**: Cast to Google Cast devices or Apple AirPlay
- 🔊 **Smart Recognition**: Recognizes various formats like "John 3:16", "John chapter 3 verse 16", etc.
- 📖 **Bible Integration**: Fetches verses from Bible APIs with fallback to common verses

## Usage

1. Tap the microphone button (bottom right)
2. Say a Bible verse reference (e.g., "John 3:16", "Romans 8:28")
3. The verse will appear on screen
4. Use the cast button to display on external screens

## Voice Recognition Examples

The app recognizes these formats:
- "John 3:16"
- "Romans 8:28"  
- "1 Corinthians 13:4"
- "John chapter 3 verse 16"
- "Psalms 23:1"

## Casting

- **Phone Screen**: Shows user controls and the verse
- **Cast Screen**: Shows only the verse in large, readable text
- **Dual Screen Mode**: Controls on phone, verse on cast display

## Getting Started

### Prerequisites

- Flutter SDK 3.0.0 or higher
- Android Studio / Xcode for mobile development
- Chrome for web development

### Installation

1. Clone the repository:
```bash
git clone https://github.com/isaacdomini/bible_verse.git
cd bible_verse
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
# For mobile
flutter run

# For web
flutter run -d chrome
```

## Permissions

### Android
- `RECORD_AUDIO`: For voice recognition
- `INTERNET`: For Bible verse lookup
- `ACCESS_NETWORK_STATE`: For casting

### iOS
- `NSMicrophoneUsageDescription`: For voice recognition
- `NSSpeechRecognitionUsageDescription`: For speech recognition

## Architecture

- `main.dart`: App entry point
- `home_screen.dart`: Main UI with voice recognition
- `cast_screen.dart`: Casting display screen
- `bible_service.dart`: Bible verse lookup service
- `cast_service.dart`: Google Cast/AirPlay integration

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## License

This project is licensed under the MIT License.