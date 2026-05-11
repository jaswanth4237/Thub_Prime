# THUB PRIME Frontend

Flutter frontend for the Thub Prime educational feedback and attendance platform.

## Project Description

The frontend provides a cross-platform UI for students and faculty to:

- authenticate and manage profiles
- view class and course details
- mark attendance
- submit session feedback
- review mentor analytics and feedback summaries

It is built with Flutter and connects to the backend API over REST.

## Requirements

- Flutter 3.10+ and Dart SDK
- Android Studio / Xcode for mobile builds
- Web browser or desktop runtime for local testing
- Node.js backend running at `http://localhost:7100`

## Dependencies

The frontend depends on the following primary packages configured in `pubspec.yaml`:

- `flutter` (SDK)
- `cupertino_icons` — iOS-style icons
- `device_preview` — device preview support during development
- `http` — REST API requests
- `provider` — state management

## Installation

Open a terminal and run:

```powershell
cd frontend
flutter pub get
```

Optionally verify your environment:

```powershell
flutter doctor
```

## Running the App

Start the backend first, then run the Flutter app.

### Run on default device

```powershell
cd frontend
flutter run
```

### Run on web

```powershell
flutter run -d chrome
```

### Run on Windows desktop

```powershell
flutter run -d windows
```

### Run on Android emulator

```powershell
flutter run -d android
```

### Run on iOS simulator (macOS only)

```powershell
flutter run -d ios
```

## Build Instructions

### Android

```powershell
flutter build apk
```

### Web

```powershell
flutter build web
```

### Windows

```powershell
flutter build windows
```

### iOS

```powershell
flutter build ios
```

## How It Connects to the Backend

The backend base URL is resolved in `lib/api_config.dart`.

Default mappings:

- desktop/web: `http://localhost:7100`
- Android emulator: `http://10.0.2.2:7100`

Override the backend URL with:

```powershell
flutter run --dart-define=API_BASE_URL=http://localhost:7100
```

## Architecture Summary

The app uses a simple MVC-style structure:

- `lib/main.dart` — app entry point
- `lib/screens/` — individual UI screens
- `lib/providers/` — state management and repository logic
- `lib/models/` — data models and enums
- `lib/widgets/` — reusable UI components
- `lib/api_config.dart` — backend API configuration

## Feature Summary

- Login/Register flow
- Course detail viewing
- Attendance validation and submission
- Feedback form submission
- Mentor dashboard and analytics
- Blocked access handling

## Testing

### Run Flutter tests

If test cases exist, run:

```powershell
cd frontend
flutter test
```

### Manual verification

- Confirm the backend is running at `http://localhost:7100`
- Open the app and log in
- Navigate through feedback and mentor screens

## Screens

- `Login / Register`
- `Course Detail`
- `Feedback Form`
- `Mentor Screen`
- `Thank You`
- `Block Screen`

## Notes

- Ensure the backend server is started before running the frontend.
- The app currently uses REST calls to the backend and relies on the backend running on port `7100`.
- Use `API_BASE_URL` to point to a different backend host if needed.
