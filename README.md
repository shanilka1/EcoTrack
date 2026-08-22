# EcoTrack

> **A modern, gamified environmental habit-tracking and sustainability platform built with Flutter and Firebase.**

---

## 📱 About the Project

**EcoTrack** is a cross-platform mobile and web application designed to inspire individuals and communities to adopt sustainable lifestyles. By turning everyday green actions into an engaging, gamified experience, EcoTrack empowers users to log eco-friendly activities, participate in community challenges, track their carbon-reduction impact, unlock milestone achievements, and compete on a live community leaderboard.

Built on **Flutter** and backed by **Firebase Cloud Services**, EcoTrack delivers an intuitive, responsive, and secure experience with atomic backend transaction validation, real-time synchronization, and comprehensive administrative controls.

---

## ✨ Features

### 👤 User Features
* **Authentication**: Secure email/password registration, login, and password reset flows with real-time field validation.
* **User Profiles**: Comprehensive profile management displaying full name, avatar, email, Eco Points, current tier, and activity audit counts.
* **Profile Settings**: Profile editing, secure password changes, and legal disclosures (Privacy Policy, Terms of Service).

### 🌱 Eco Activities
* **Activity Catalog**: Browse verified sustainability activities across categories such as Waste, Transport, Energy, Food, and Nature.
* **Activity Details**: Detailed information including environmental benefits, point rewards, and action guides.
* **Daily Action Logging**: Log completed actions with duplicate-safe daily keys and automatic point crediting.
* **Search & Multi-Facet Filtering**: Real-time 250ms debounced search by title, description, category chips, and point range filters.

### 🎯 Challenges
* **Sustainability Challenges**: Timed green challenges (e.g., *Zero Waste Week*, *Green Commuter Sprint*) with target metrics.
* **Progress Tracking**: Real-time progress calculation linked directly to logged eco activities.
* **Challenge Statuses**: Distinct tabs for Active, Completed, and Expired challenges.
* **Reward Claims**: Single-claim reward points credited upon achieving 100% of the challenge target.

### 🏆 Gamification
* **Secure Eco Points**: Points earned through activities and challenges, recalculating level tiers dynamically.
* **Achievements & Badges**: Tiered milestones (*First Green Step*, *Eco Century*, *Waste Warrior*, *Eco Champion*) unlocked automatically upon meeting requirement thresholds.
* **Community Leaderboard**: Real-time ranking podium highlighting top green contributors and the authenticated user's current rank without exposing private user data.

### 📊 Progress & Analytics
* **KPI Impact Overview**: Centralized summary of total Eco Points, completed activities, completed challenges, and unlocked badges.
* **Weekly Activity Trends**: Responsive chart visualizations mapping daily activity counts and earned points.
* **Category Breakdown**: Percentage distribution of green actions across all sustainability categories.

### 🔔 Notifications
* **In-App Notification Stream**: Real-time notifications triggered by activity completions, challenge finishes, badge unlocks, and level-ups.
* **Read / Unread States**: Tap to mark individual items as read or mark all notifications as read simultaneously.

### 👨‍💼 Admin Features
* **Role-Protected Admin Console**: Separate administrative interface accessible only to verified `admin` roles.
* **Live System Metrics**: Real-time counters for total registered users, active activities, ongoing challenges, badges, and announcements.
* **Activity Management**: Full CRUD console to create, update, and soft-deactivate eco activities.
* **Challenge Management**: Configure challenge titles, target categories, completion requirements, rewards, and duration dates.
* **Achievement Management**: Define badge rules, requirement types, and values.
* **User Directory**: Privacy-safe user directory search and activity statistics inspection.
* **System Announcements**: Broadcast system-wide announcements to all active users.

### 🔐 Security
* **Least-Privilege Firestore Rules**: Strict permission enforcement separating public catalogs from private subcollections.
* **Atomic Point Transactions**: Point allocations and duplicate checks execute exclusively within atomic Firestore transactions (`runTransaction`).
* **Role Tampering Protection**: User roles (`role`) and critical timestamps (`createdAt`) are immutable by client-side requests.
* **Sanitized Error Feedback**: Technical database exceptions are sanitized to prevent internal architecture leaks.

---

## 🛠️ Technology Stack

| Technology | Purpose |
|---|---|
| **Flutter** | Cross-platform UI toolkit for building responsive Mobile (Android/iOS) and Web applications |
| **Dart** | Modern, client-optimized programming language powering application logic and data models |
| **Firebase Authentication** | Secure user identity management, session tokens, and password reset workflows |
| **Cloud Firestore** | NoSQL cloud database providing real-time data synchronization and atomic transactions |
| **Firebase Storage** | Secure cloud object storage for user profile photos and administrative media |
| **Firebase Cloud Messaging** | Infrastructure for push notifications and real-time user event messaging |
| **Firebase Hosting** | Fast and secure global hosting for the Flutter Web deployment |

---

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Flutter Mobile / Web App                 │
│         (Presentation Layer: Screens, Widgets, Theme)       │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                   Repositories & Services                   │
│      (AuthService, ActivityService, ChallengeService, etc.) │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│               Firebase Authentication (Identity)            │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                  Cloud Firestore (Database)                 │
│         • Atomic Transactions (runTransaction)              │
│         • Least-Privilege Security Rules (firestore.rules)  │
│         • Composite Indexes (firestore.indexes.json)        │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│              Firebase Storage & Cloud Messaging             │
│        (Avatar uploads, assets, and broadcast alerts)       │
└─────────────────────────────────────────────────────────────┘
```

### Layer Responsibilities

1. **Presentation Layer (`lib/features/*/screens` & `widgets`)**:
   * Pure UI rendering adapting to screen sizes (320px mobile to desktop).
   * Material 3 visual identity with Light and Dark mode themes.
   * State management handling Loading, Loaded, Empty, and Error states.

2. **Domain & Data Layer (`lib/features/*/models` & `services`)**:
   * Data parsing (`fromFirestore`, `toMap`) and business models.
   * Service repositories executing atomic Firestore operations, caching catalogs, and debouncing user search inputs.

3. **Security & Backend Layer (`firestore.rules`, `storage.rules`, `firebase_options.dart`)**:
   * Authoritative role validation (`isAdmin()`, `isOwner()`).
   * Audit log immutability (`completedActivities`, `unlockedAchievements`).
   * Atomic point integrity protecting against client-side tampering.

---

## 📂 Project Structure

```
lib/
├── app.dart                                # Root MaterialApp configuration & theme setup
├── firebase_options.dart                   # Generated Firebase platform configurations
├── main.dart                               # Application entry point with Firebase initialization
├── core/
│   ├── constants/                          # Design tokens, colors, typography, strings, and spacing
│   │   ├── app_colors.dart
│   │   ├── app_constants.dart
│   │   ├── app_strings.dart
│   │   └── app_typography.dart
│   ├── exceptions/                         # Custom exception classes
│   ├── routes/                             # Centralized AppRoutes generator
│   │   └── app_routes.dart
│   ├── theme/                              # Light and Dark ThemeData definitions
│   │   └── app_theme.dart
│   ├── utils/                              # Utility helpers (Debouncer, ErrorSanitizer, LevelCalculator, ResponsiveHelper)
│   └── widgets/                            # Reusable UI components (Buttons, Cards, TextFields, Skeletons, SearchFilterBar)
└── features/
    ├── activities/                         # Activities catalog, details, search & filters
    │   ├── models/
    │   ├── screens/
    │   ├── services/
    │   └── widgets/
    ├── admin/                              # Admin dashboard, consoles (Activities, Challenges, Badges, Users, Announcements)
    ├── auth/                               # Registration, Login, UserModel & AuthService
    ├── challenges/                         # Environmental challenges, progress tracking & rewards
    ├── home/                               # Home dashboard, level tier card, quick actions
    ├── leaderboard/                        # Community rankings, podium & LeaderboardService
    ├── notifications/                      # In-app notifications & NotificationService
    ├── onboarding/                         # First-launch onboarding walkthrough
    ├── profile/                            # Profile screen, edit profile, change password, settings & legal info
    ├── progress/                           # User statistics, KPI cards & trend charts
    ├── rewards/                            # Achievements, badges & AchievementService
    └── splash/                             # Animated splash screen & destination routing
```

---

## 🔐 Security & Data Integrity

EcoTrack enforces enterprise-grade security standards across all layers:

* **Authoritative Role-Based Access Control**:
  Administrative access to `/admin` and global collections (`ecoActivities`, `challenges`, `achievements`, `announcements`) is strictly gated by evaluating `users/{uid}.role == 'admin'` and Firebase auth token claims.
* **Atomic Point & Completion Logic**:
  Points are never incremented arbitrarily from the client. Activity completions execute inside Firestore atomic transactions (`_firestore.runTransaction`), verifying official points from the catalog, preventing daily duplicate entries, and logging immutable audit records in `users/{uid}/completedActivities`.
* **Immutable Audit Trails**:
  Completed activities and unlocked achievements subcollections have update rules locked (`allow update: if false;`), ensuring reward history cannot be modified after the fact.
* **Protected Profile Fields**:
  Normal users can only update safe fields (`fullName`, `photoUrl`, `preferences`). Key fields such as `uid`, `role`, `ecoPoints`, and `createdAt` are protected against user tampering.
* **Secrets Management**:
  Keystores (`*.jks`, `*.keystore`), signing properties (`key.properties`), environment files (`*.env`), and service account credentials (`service-account*.json`) are excluded via `.gitignore`.

---

## 🚀 Getting Started

### Prerequisites

Ensure you have the following installed on your development machine:

* **Flutter SDK**: `>=3.19.0` ([Install Flutter](https://docs.flutter.dev/get-started/install))
* **Dart SDK**: Included with Flutter
* **IDE**: Android Studio or Visual Studio Code (with Flutter & Dart extensions)
* **Firebase CLI**: `>=13.0.0` ([Install Firebase CLI](https://firebase.google.com/docs/cli))
* **Git**: For version control

---

### Installation & Setup

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/shanilka1/EcoTrack.git
   cd EcoTrack
   ```

2. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**:
   Connect your Firebase project using the FlutterFire CLI:
   ```bash
   flutterfire configure --project=ecotrack-100ff
   ```

4. **Deploy Backend Security Rules & Indexes**:
   ```bash
   firebase deploy --only firestore,storage
   ```

5. **Run Static Code Analysis**:
   ```bash
   flutter analyze
   ```

6. **Run Automated Test Suites**:
   ```bash
   flutter test
   ```

7. **Launch the Application**:
   * **For Mobile (Android/iOS)**:
     ```bash
     flutter run
     ```
   * **For Web**:
     ```bash
     flutter run -d chrome
     ```

---

## 🌐 Live Web Demo

Experience the live deployed version on Firebase Hosting:
* **Primary URL**: [https://ecotrack-100ff.web.app](https://ecotrack-100ff.web.app)
* **Alternative URL**: [https://ecotrack-100ff.firebaseapp.com](https://ecotrack-100ff.firebaseapp.com)

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).