# 🔥 FireGuard

A comprehensive wildfire detection and community alert system built with Flutter. FireGuard leverages real-time satellite data, AI-powered assistance, and community reporting to help users stay safe from wildfires.

<div align="center">
  <img src="https://media.tenor.com/images_or_your_chosen_gif_id/fire-animation.gif" alt="Fire Animation" width="600"/>
</div>

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Screenshots](#screenshots)
- [Tech Stack](#tech-stack)
- [Architecture](#architecture)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
  - [Configuration](#configuration)
- [Usage](#usage)
- [Firebase Functions](#firebase-functions)
- [Project Structure](#project-structure)
- [Contributing](#contributing)
- [License](#license)

## 🌟 Overview

FireGuard is a mobile application designed to protect communities from wildfires through:
- **Real-time satellite monitoring** of fire hotspots using NASA FIRMS data
- **Community-driven reporting** system for rapid fire incident alerts
- **Proximity-based notifications** to warn users of nearby fires
- **AI-powered companion** for fire safety guidance and emergency assistance
- **Interactive mapping** with geospatial fire tracking
- **Compass navigation** to help users navigate away from danger zones

<div align="center">
  <img src="https://media.tenor.com/images_or_your_app_demo_gif/demo.gif" alt="App Demo" width="300"/>
</div>

## ✨ Features

### 🗺️ Real-Time Fire Map
- Displays active fire hotspots from multiple satellite sources (MODIS, VIIRS, Landsat)
- Color-coded markers based on fire intensity and confidence levels
- Interactive map with zoom and pan capabilities
- Fire details including FRP (Fire Radiative Power), confidence, and acquisition time

### 📍 Community Reports
- User-submitted fire incident reports with location tagging
- Photo upload capability for incident documentation
- Description and severity level input
- Geohash-based spatial indexing for efficient queries

### 🔔 Smart Notifications
- Proximity-based alerts when fires are detected within 5km radius
- Firebase Cloud Functions trigger notifications to nearby users
- Push notifications via Firebase Cloud Messaging (FCM)
- Real-time user presence tracking with geolocation

### 🤖 AI Companion
- Gemini AI-powered assistant for fire safety information
- Emergency guidance and evacuation procedures
- Real-time Q&A about wildfire risks and prevention

### 🧭 Compass Navigation
- Built-in compass for directional navigation
- Useful for evacuations and emergency situations
- Real-time heading updates

### 🔐 Authentication
- Google Sign-In integration
- Firebase Authentication
- User profile management
- Secure session handling

![Feature Grid](docs/images/features.png)

## 📸 Screenshots

<div align="center">
  <table>
    <tr>
      <td><img src="docs/images/screenshot-map.png" alt="Map View" width="250"/><br><b>Fire Map</b></td>
      <td><img src="docs/images/screenshot-report.png" alt="Report View" width="250"/><br><b>Report Incident</b></td>
      <td><img src="docs/images/screenshot-ai.png" alt="AI Assistant" width="250"/><br><b>AI Assistant</b></td>
    </tr>
  </table>
</div>

## 🛠️ Tech Stack

### Frontend (Flutter)
- **Framework**: Flutter 3.8.1+ with Dart
- **State Management**: Riverpod 2.6.1
- **UI Components**: Material Design 3
- **Maps**: flutter_map 8.2.2 with OpenStreetMap tiles
- **Authentication**: firebase_auth 6.1.0
- **Fonts**: Google Fonts

### Backend & Services
- **Backend**: Firebase (Firestore, Auth, Cloud Functions, Cloud Messaging)
- **Geolocation**: geolocator 14.0.2
- **Geospatial Indexing**: dart_geohash 2.1.0
- **Push Notifications**: firebase_messaging 16.0.2 + flutter_local_notifications
- **AI Integration**: Gemini API (Google Generative AI)
- **HTTP Client**: http 1.1.0

### Cloud Functions
- **Runtime**: Node.js 22
- **Framework**: Firebase Functions 6.0.1
- **Admin SDK**: firebase-admin 12.6.0
- **Geospatial Queries**: geofire-common 6.0.0

### DevOps
- **Version Control**: Git
- **CI/CD**: GitHub Actions (configured in `.github`)
- **Environment Variables**: flutter_dotenv 6.0.0

![Tech Stack](docs/images/tech-stack.png)

## 🏗️ Architecture

FireGuard follows a clean architecture pattern with clear separation of concerns:

```
lib/
├── models/          # Data models (FireHotspot, ReportModel)
├── providers/       # Riverpod state providers
├── services/        # Business logic and API services
│   ├── notification_service.dart
│   ├── user_service.dart
│   ├── geocoding_service.dart
│   └── permission_service.dart
├── ui/              # User interface components
│   ├── map/         # Fire map view
│   ├── report/      # Report submission
│   ├── ai/          # AI companion chat
│   ├── compass/     # Compass navigation
│   ├── alerts/      # Alert notifications
│   ├── auth/        # Authentication screens
│   └── menu/        # Settings and profile
├── utils/           # Utilities, constants, themes
└── shell/           # App shell with bottom navigation
```

### Data Flow
1. **Satellite Data**: Fetched from NASA FIRMS API, parsed, and displayed on map
2. **User Reports**: Submitted to Firestore with geohash for spatial queries
3. **Cloud Functions**: Trigger proximity-based notifications when reports are created
4. **Real-time Updates**: Firestore listeners provide live data synchronization

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.8.1 or higher)
- Dart SDK (included with Flutter)
- Firebase account and project
- Node.js 22+ (for Cloud Functions)
- Android Studio / Xcode for mobile development
- API Keys:
  - Gemini API key (for AI features)
  - Map API key (if using custom tile server)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/fireguard.git
   cd fireguard
   ```

2. **Install Flutter dependencies**
   ```bash
   flutter pub get
   ```

3. **Install Firebase CLI**
   ```bash
   npm install -g firebase-tools
   firebase login
   ```

4. **Install Cloud Functions dependencies**
   ```bash
   cd functions
   npm install
   cd ..
   ```

### Configuration

1. **Set up Firebase**
   ```bash
   # Initialize Firebase (if not already done)
   firebase init
   
   # Generate Firebase configuration for Flutter
   flutterfire configure
   ```

2. **Configure environment variables**
   
   Copy the example environment file:
   ```bash
   cp .env.example .env
   ```
   
   Edit `.env` and add your API keys:
   ```env
   GEMINI_API_KEY=your_gemini_api_key_here
   GEN_API_KEY=your_gemini_api_key_here
   MAP_API_KEY=your_maps_api_key_here
   ```

3. **Update Firebase rules** (in Firebase Console)
   
   Set appropriate Firestore security rules for `reports` and `user_presence` collections.

4. **Deploy Cloud Functions**
   ```bash
   cd functions
   npm run deploy
   cd ..
   ```

### Running the App

```bash
# Run on connected device or emulator
flutter run

# Run in release mode
flutter run --release
```

## 📱 Usage

1. **Sign In**: Use Google Sign-In to authenticate
2. **View Map**: Browse real-time fire hotspots on the interactive map
3. **Report Fire**: Tap the report button to submit a community fire report
4. **Get Alerts**: Receive notifications when fires are reported nearby
5. **Ask AI**: Use the AI companion for fire safety guidance
6. **Navigate**: Use the compass for directional navigation during emergencies

## ☁️ Firebase Functions

The app uses Firebase Cloud Functions for server-side logic:

### `notifyUsersNearReport`
Triggered when a new report is created in Firestore:
- Queries `user_presence` collection using geohash bounds
- Finds users within 5km radius of the reported fire
- Sends FCM push notifications to nearby users
- Excludes the report author from notifications

To test locally:
```bash
cd functions
npm run serve
```

## 📂 Project Structure

```
fireguard/
├── android/                 # Android native code
├── ios/                     # iOS native code
├── lib/                     # Flutter application code
│   ├── models/              # Data models
│   ├── providers/           # State management
│   ├── services/            # Business logic
│   ├── ui/                  # UI screens
│   └── utils/               # Helpers and constants
├── functions/               # Firebase Cloud Functions
│   ├── src/
│   │   └── index.ts         # Function definitions
│   └── package.json
├── test/                    # Unit and widget tests
├── web/                     # Web platform files
├── .env.example             # Environment variables template
├── pubspec.yaml             # Flutter dependencies
├── firebase.json            # Firebase configuration
└── README.md                # This file
```

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

**Built with ❤️ for community safety and wildfire prevention**
