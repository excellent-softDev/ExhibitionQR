# ExhibitionQR

A Flutter mobile application for tracking visitor interactions with exhibition exhibits using QR codes and Firebase backend.

## Features

### Core Functionality
- **QR Code Scanning**: Scan QR codes placed at exhibit stations
- **Visitor Session Tracking**: Track when users start and end their exhibition visit
- **Data Collection**: Store scan timestamps, exhibit IDs, and visit durations
- **Authentication**: Support for admin login and anonymous guest access
- **Offline Support**: Works offline and syncs data when internet is available

### Analytics Dashboard
- **Most Visited Exhibits**: Bar chart showing popular exhibits
- **Visit Statistics**: Number of visits per exhibit and average time spent
- **Peak Hours Analysis**: Hourly visitor traffic patterns
- **Overall Statistics**: Total exhibits, visits, and active sessions

### User Experience
- **Modern UI**: Clean, Material Design 3 interface
- **Real-time Updates**: Instant feedback and data synchronization
- **Visit History**: View personal exhibition journey
- **Error Handling**: Comprehensive error messages and recovery options

## Tech Stack

- **Frontend**: Flutter 3.10+
- **Language**: Dart 3.0+
- **Backend**: Firebase (Firestore, Authentication, Analytics)
- **State Management**: Provider pattern
- **Charts**: fl_chart for analytics visualization
- **QR Scanning**: mobile_scanner
- **Offline Storage**: SharedPreferences

## Prerequisites

- Flutter SDK 3.10 or higher
- Dart 3.0 or higher
- Android Studio / VS Code with Flutter extensions
- Firebase account
- Physical device or emulator with camera support

## Installation

### 1. Clone the Repository

```bash
git clone https://github.com/excellent-softDev/ExhibitionQR.git
cd ExhibitionQR
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Firebase Setup

Follow the detailed setup instructions in [FIREBASE_SETUP.md](./FIREBASE_SETUP.md):

1. Create a Firebase project
2. Add Android and iOS apps
3. Enable Authentication (Email/Password + Anonymous)
4. Set up Firestore Database
5. Configure security rules
6. Add configuration files

### 4. Run the App

```bash
# For Web
flutter run -d chrome

# For Android
flutter run

# For iOS
flutter run -d ios

# For specific device
flutter run -d <device-id>
```

## Project Structure

```
lib/
|-- main.dart                 # App entry point
|-- firebase_options.dart      # Firebase configuration
|-- models/                   # Data models
|   |-- exhibit.dart         # Exhibit, Visit, Session models
|-- services/                 # Business logic
|   |-- auth_service.dart    # Authentication
|   |-- exhibit_service.dart # Exhibit operations
|   |-- analytics_service.dart # Analytics calculations
|   |-- offline_service.dart # Offline sync
|-- providers/               # State management
|   |-- user_provider.dart   # User state
|   |-- exhibit_provider.dart # Exhibit state
|-- screens/                  # UI screens
|   |-- auth_wrapper.dart    # Authentication wrapper
|   |-- auth_screen.dart     # Login screen
|   |-- home_screen.dart     # Main dashboard
|   |-- qr_scanner_screen.dart # QR scanner
|   |-- visit_history_screen.dart # Visit history
|   |-- analytics_screen.dart # Analytics dashboard
|-- widgets/                 # Reusable widgets
|   |-- loading_widget.dart  # Loading indicators
|-- utils/                   # Utilities
|   |-- constants.dart       # App constants
|   |-- error_handler.dart   # Error handling
```

## Configuration

### Firebase Configuration

Update `lib/firebase_options.dart` with your Firebase project configuration:

```dart
// Replace placeholder values with your actual Firebase config
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'your-android-api-key',
  appId: 'your-android-app-id',
  // ... other config
);
```

### QR Code Format

QR codes should contain simple exhibit IDs (alphanumeric with hyphens and underscores):

```
exhibit_001
ancient_artifacts
hall-a-section-1
```

## Usage

### For Visitors

1. **Launch the App**: Open ExhibitionQR
2. **Auto Sign-In**: Automatically signed in as guest for immediate access
3. **Scan QR Codes**: Point camera at QR codes at exhibit stations
4. **View History**: Check your visit history in the History tab
5. **View Analytics**: See exhibition statistics in the Analytics tab

### For Administrators

1. **Login as Admin**: Use admin credentials to access dashboard
   - Username: `admin`
   - Password: `admin123`
2. **Set Up Exhibits**: Create exhibit documents in Firestore
3. **Generate QR Codes**: Create QR codes with exhibit IDs
4. **Place QR Codes**: Position QR codes at exhibit stations
5. **Monitor Analytics**: Track visitor engagement through the dashboard

## Data Models

### Exhibit
```dart
{
  "id": "exhibit_001",
  "name": "Ancient Artifacts",
  "description": "Collection description",
  "location": "Hall A, Section 1",
  "createdAt": "2024-01-01T00:00:00Z"
}
```

### Exhibit Visit
```dart
{
  "id": "visit_123",
  "sessionId": "session_456",
  "exhibitId": "exhibit_001",
  "userId": "user_789",
  "scanTime": "2024-01-01T10:30:00Z",
  "leaveTime": "2024-01-01T10:45:00Z",
  "duration": 900
}
```

### User Session
```dart
{
  "id": "session_456",
  "userId": "user_789",
  "startTime": "2024-01-01T10:00:00Z",
  "endTime": "2024-01-01T12:30:00Z",
  "isActive": false
}
```

## API Reference

### AuthService
- `signInAsAdmin(username, password)`: Admin authentication
- `signInAnonymously()`: Guest authentication
- `signOut()`: Sign out user
- `getUserData(uid)`: Get user information

### ExhibitService
- `recordExhibitVisit(exhibitId)`: Record exhibit visit
- `getAllExhibits()`: Get all exhibits
- `getUserVisitHistory()`: Get user's visit history
- `endUserSession()`: End current session

### AnalyticsService
- `getMostVisitedExhibits()`: Get popular exhibits
- `getExhibitStatistics(exhibitId)`: Get exhibit analytics
- `getOverallAnalytics()`: Get overall statistics
- `getPeakVisitingHours()`: Get hourly traffic data

## Testing

### Run Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Run with coverage
flutter test --coverage
```

## Deployment

### Android

1. **Generate Keystore**:
   ```bash
   keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

2. **Build APK**:
   ```bash
   flutter build apk --release
   ```

3. **Build App Bundle**:
   ```bash
   flutter build appbundle --release
   ```

### iOS

1. **Configure Xcode**: Open `ios/Runner.xcworkspace`
2. **Set Bundle Identifier**: Update to your unique identifier
3. **Code Signing**: Configure provisioning profiles
4. **Build Archive**: Product → Archive

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For support and questions:
- Create an issue on GitHub
- Check the [FIREBASE_SETUP.md](./FIREBASE_SETUP.md) for setup issues

---

**Built with :heart: using Flutter**
