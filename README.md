# 📋 TaskFlow — Flutter Task Manager App

A **production-ready, professional Flutter Task Manager App** with Firebase Authentication, Cloud Firestore, REST API integration, and beautiful Material 3 UI.

---

## ✨ Features

- 🔐 **Firebase Authentication** — Sign up, login, logout with email & password
- ✅ **Task Management** — Add, edit, delete, mark complete with real-time sync
- 💬 **Motivational Quotes** — Fetched from `https://api.quotable.io/random`
- 🌗 **Dark / Light Mode** — System-aware Material 3 theming
- 📱 **Android & iOS** support

---

## 📁 Folder Structure

```
lib/
├── screens/
│   ├── splash_screen.dart
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── home_screen.dart
│   └── add_edit_task_screen.dart
│
├── services/
│   ├── auth_service.dart
│   ├── firestore_service.dart
│   └── api_service.dart
│
├── models/
│   ├── task_model.dart
│   └── quote_model.dart
│
├── widgets/
│   ├── custom_button.dart
│   ├── custom_textfield.dart
│   ├── task_card.dart
│   ├── loading_widget.dart
│   └── quote_card.dart
│
├── firebase_options.dart     ← Replace with FlutterFire CLI output
└── main.dart
```

---

## 🔧 Setup Instructions

### Prerequisites
- Flutter SDK >= 3.5.0
- Dart SDK >= 3.5.0
- A Firebase project
- Android Studio / VS Code
- [FlutterFire CLI](https://firebase.flutter.dev/docs/cli)

---

### Step 1 — Clone & Install Dependencies

```bash
cd task_manager_app
flutter pub get
```

---

### Step 2 — Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **Add Project** → Name it (e.g., `task-manager-app`)
3. Enable **Google Analytics** (optional)

---

### Step 3 — Enable Firebase Services

#### Authentication
1. Firebase Console → **Authentication** → **Get Started**
2. Enable **Email/Password** provider

#### Cloud Firestore
1. Firebase Console → **Firestore Database** → **Create Database**
2. Choose **Start in test mode** (for development)
3. Select your preferred region

---

### Step 4 — Configure Firebase with FlutterFire CLI

```bash
# Install FlutterFire CLI globally
dart pub global activate flutterfire_cli

# Configure Firebase for your Flutter project
flutterfire configure
```

This auto-generates `lib/firebase_options.dart` with your real credentials.
> ⚠️ Replace the placeholder `lib/firebase_options.dart` with the generated one.

---

### Step 5 — Android Setup

1. In Firebase Console → **Project Settings** → **Your Apps** → Android
2. Download `google-services.json`
3. Place it in: `android/app/google-services.json`

Verify `android/build.gradle` has:
```groovy
dependencies {
    classpath 'com.google.gms:google-services:4.4.0'
}
```

Verify `android/app/build.gradle` has:
```groovy
apply plugin: 'com.google.gms.google-services'

android {
    compileSdkVersion 34
    minSdkVersion 21
}
```

---

### Step 6 — iOS Setup

1. In Firebase Console → **Project Settings** → **Your Apps** → iOS
2. Download `GoogleService-Info.plist`
3. Open Xcode → drag `GoogleService-Info.plist` into `ios/Runner/`
4. Minimum iOS deployment target: **12.0**

In `ios/Podfile`:
```ruby
platform :ios, '12.0'
```

---

### Step 7 — Firestore Security Rules

In Firebase Console → **Firestore** → **Rules**, set:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/tasks/{taskId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

---

### Step 8 — Run the App

```bash
# Run on Android
flutter run

# Run on iOS
flutter run -d ios
```

---

## 🏗️ Build APK (Android)

```bash
# Build release APK
flutter build apk --release

# Output location:
# build/app/outputs/flutter-apk/app-release.apk
```

### Build Split APKs (smaller size)
```bash
flutter build apk --split-per-abi --release
```

---

## 🍎 Build iOS (IPA)

```bash
flutter build ipa --release
```

Open `build/ios/archive/Runner.xcarchive` in Xcode to distribute.

---

## 🗄️ Firestore Data Structure

```
users/
└── {userId}/
    └── tasks/
        └── {taskId}/
            ├── title:       "Buy groceries"
            ├── description: "Milk, eggs, bread"
            ├── date:        "May 10, 2025"
            ├── isCompleted: false
            └── createdAt:   Timestamp
```

---

## 📦 Dependencies

| Package | Purpose |
|---|---|
| `firebase_core` | Firebase initialization |
| `firebase_auth` | Email/password authentication |
| `cloud_firestore` | Real-time task database |
| `http` | REST API calls for quotes |
| `provider` | State management |
| `intl` | Date formatting |

---

## 🌐 API Integration

- **Endpoint:** `https://api.quotable.io/random`
- **Method:** GET
- **Response fields used:** `content`, `author`
- Tap the 🔄 refresh button on the quote card to fetch a new quote.

---

## 🏗️ Architecture

```
UI (Screens)
    ↕
Services (AuthService, FirestoreService, ApiService)
    ↕
Firebase (Auth + Firestore) / REST API
```

- **Clean Separation:** UI never directly calls Firebase SDK
- **Reusable Widgets:** `CustomButton`, `CustomTextField`, `TaskCard`, `QuoteCard`, `LoadingWidget`
- **Error Handling:** All async operations wrapped with try/catch + user-friendly Snackbars

---

## 🎨 UI Highlights

- Material 3 design with dynamic color theming
- Gradient headers on auth screens
- Animated splash screen
- Shimmer-effect loading states on QuoteCard
- Animated task completion toggle (circle checkbox)
- Empty state with helpful illustrations
- System-aware dark/light mode
