# EcoTrack Release & Quality Assurance Manual Checklist

This document provides a comprehensive verification checklist for validating the EcoTrack Flutter application before production release to Google Play Store and Apple App Store.

---

## 1. Authentication & Security Flows

- [ ] **Registration Flow**:
  - [ ] Submit empty fields -> Verify clear inline validation errors.
  - [ ] Submit invalid email (e.g. `user@`) -> Verify format error.
  - [ ] Submit password with `< 6` characters -> Verify minimum length error.
  - [ ] Mismatch Confirm Password -> Verify error message.
  - [ ] Valid inputs -> Verify Firebase Auth account creation, Firestore `users/{uid}` profile creation (`role: "user"`, `ecoPoints: 0`, `level: 1`), and automatic navigation to Home.

- [ ] **Login Flow**:
  - [ ] Submit empty credentials -> Verify required field validation.
  - [ ] Submit non-existent or wrong password -> Verify sanitized error *"Invalid email or password"*.
  - [ ] Valid credentials -> Verify authenticated login, role retrieval, and navigation to Home (or Admin Console if `role == 'admin'`).

- [ ] **Sign Out Flow**:
  - [ ] Tap Logout from Profile Screen -> Confirm dialog -> Verify session termination and redirect to Login Screen.
  - [ ] Attempt back-navigation after logout -> Verify access to protected screens is denied.

---

## 2. Home Dashboard & Live Backend Integration

- [ ] **User Header & Stats**:
  - [ ] Verify user full name, avatar placeholder, eco points, and level tier reflect real Firestore document data.
  - [ ] Verify Unread Notifications badge bell counter updates in real-time.
- [ ] **Admin Banner**:
  - [ ] Normal User (`role: "user"`) -> Verify Admin banner and Admin menu options are hidden.
  - [ ] Admin User (`role: "admin"`) -> Verify Admin Console banner and avatar menu item are visible.
- [ ] **Quick Action Shortcuts**:
  - [ ] Tap "Log Activity" -> Navigates to Activities Screen.
  - [ ] Tap "Challenges" -> Navigates to Challenges Screen.
  - [ ] Tap "Leaderboard" -> Navigates to Leaderboard Screen.
  - [ ] Tap "My Impact" -> Navigates to Progress Screen.

---

## 3. Eco Activities & Point System

- [ ] **Search & Multi-Facet Filtering**:
  - [ ] Type query in search field -> Verify activities filter by Title, Description, and Category.
  - [ ] Select Category chip -> Verify activity list filters accordingly.
  - [ ] Open Filter Sheet -> Select Points Range (`1 - 20 pts`, `21 - 50 pts`, `50+ pts`) -> Verify list updates.
  - [ ] Tap "Clear All" -> Verify filters reset and full active activity catalog is restored.
  - [ ] Search for non-existent term -> Verify *"No matching activities found"* and "Clear Filters" action.
- [ ] **Activity Details & Completion**:
  - [ ] Tap an activity -> Verify complete details, points badge, and environmental impact description.
  - [ ] Tap "Complete Activity" -> Verify atomic Firestore transaction executes.
  - [ ] Verify points awarded, level recalculation, completion record creation in `users/{uid}/completedActivities`, and in-app notification dispatch.
  - [ ] Tap "Complete Activity" again on the same day -> Verify duplicate prevention message *"You have already completed this activity today"*.

---

## 4. Challenges & Rewards

- [ ] **Status Categorization**:
  - [ ] Active Tab -> Displays ongoing uncompleted challenges.
  - [ ] Completed Tab -> Displays challenges with 100% target progress.
  - [ ] Expired Tab -> Displays ended challenges.
- [ ] **Progress Tracking**:
  - [ ] Completing an activity matching a challenge category -> Verify challenge progress increment in real time.
  - [ ] Completing challenge target -> Verify reward points are awarded and notification is dispatched once.

---

## 5. Achievements & Badges

- [ ] **Badge List**:
  - [ ] Unlocked Badges -> Display in full color with claim timestamp.
  - [ ] Locked Badges -> Display in greyed-out locked state with requirement progress info.
- [ ] **Automated Unlock**:
  - [ ] Logging first activity -> Verify "First Step" badge unlocks.
  - [ ] Reaching 100 points -> Verify "Eco Century" badge unlocks.

---

## 6. Leaderboard & Progress Analytics

- [ ] **Leaderboard**:
  - [ ] Verify Top 3 podium highlights ranks 1, 2, and 3.
  - [ ] Verify user ranking list is sorted by `ecoPoints` descending.
  - [ ] Verify current logged-in user is highlighted in the list or sticky bottom bar.
  - [ ] Verify no private information (passwords, emails, tokens) is rendered.
- [ ] **My Progress & Charts**:
  - [ ] Verify KPI metric cards (Total Points, Completed Activities, Challenges, Badges).
  - [ ] Verify Weekly Trend bar chart and Category Breakdown render cleanly without overflow on mobile devices.

---

## 7. Profile, Notifications & Settings

- [ ] **Edit Profile**:
  - [ ] Update Full Name -> Verify changes reflect in Firestore and Home Dashboard.
- [ ] **Notifications**:
  - [ ] Tap unread notification -> Verify item marks as read.
  - [ ] Tap "Mark All Read" -> Verify all notifications transition to read state.
- [ ] **Legal & Info**:
  - [ ] View Privacy Policy & Terms -> Verify complete legal text renders without layout clipping.

---

## 8. Admin Management Consoles (Admin Account Only)

- [ ] **Access Guard**:
  - [ ] Navigate to `/admin` as normal user -> Verify *"Access Denied"* screen.
  - [ ] Navigate to `/admin` as admin -> Verify Live System Metrics (Total Users, Activities, Challenges, Badges, Announcements).
- [ ] **CRUD Consoles**:
  - [ ] Activities: Add new activity, Edit activity, Soft-deactivate/activate.
  - [ ] Challenges: Add new challenge with target & reward, toggle status.
  - [ ] Badges: Add new badge with requirement criteria.
  - [ ] User Directory: Search users by name/email, inspect non-sensitive statistics.
  - [ ] Announcements: Publish new broadcast message.

---

## 9. Security & Error Resilience

- [ ] **Tamper-Proofing**:
  - [ ] Verify client cannot mutate `role`, `uid`, `createdAt`, or arbitrary `ecoPoints` via direct Firestore calls.
- [ ] **Network Failure**:
  - [ ] Disable device Wi-Fi/data -> Verify user-friendly error message and "Retry" button rather than app crash or raw exception logs.
