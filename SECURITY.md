# EcoTrack Security Architecture & Backend Hardening Guide

This document outlines the security architecture, authorization models, Firestore rules, Storage policies, and backend hardening mechanisms implemented across the EcoTrack application.

---

## 1. Authentication Model

* **Provider**: Firebase Authentication (Email/Password).
* **Token Lifecycle**: All requests to Firestore and Firebase Storage include an authenticated JSON Web Token (JWT) cryptographically verified by Firebase.
* **Credentials Storage**: Passwords are never stored in Firestore documents. All credential verification is handled securely by Firebase Auth.
* **Session Termination**: Calling `AuthService.signOut()` clears local cache and revokes active tokens.

---

## 2. Authorization & Role-Based Access Control (RBAC)

EcoTrack implements strict **Least-Privilege Authorization** with two authoritative roles:

| Role | Permissions |
|---|---|
| `user` | Read active activities, challenges, achievements, announcements, own profile, and public leaderboard. Complete activities (via atomic transactions), update non-sensitive profile info, manage own notifications and settings. |
| `admin` | Full CRUD privileges on `ecoActivities`, `challenges`, `achievements`, and `announcements`. Access to administrative user directory and aggregated metrics. |

### Role Tamper-Proofing
* Normal users cannot promote themselves or modify their own `role` field.
* Firestore Security Rules explicitly reject updates where `affectedKeys().hasAny(['role', 'uid', 'createdAt'])`.
* Admin checks in Firestore rules:
  ```javascript
  function isAdmin() {
    return isAuthenticated() && (
      (request.auth.token.role == 'admin') ||
      (exists(/databases/$(database)/documents/users/$(request.auth.uid)) &&
       get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin')
    );
  }
  ```

---

## 3. Authoritative Eco Points & Points Integrity

To prevent client-side manipulation of points, rewards, or levels:

1. **Server-Sourced Values**: Activity point values are read directly from the backend Firestore document (`ecoActivities/{activityId}`) inside an atomic transaction. Client-provided points are completely ignored.
2. **Atomic Firestore Transactions**: `ActivityService.completeActivity` runs within `FirebaseFirestore.instance.runTransaction()` to atomically:
   - Verify activity validity and active status.
   - Check duplicate completion key (`${activityId}_${yyyyMMdd}`).
   - Update user profile `ecoPoints` and recalculate `level`.
   - Update active challenge progressions and claim eligible rewards.
   - Award unlocked achievement badges.
   - Dispatch real-time in-app notifications.
3. **Immutable Completion Records**: `completedActivities` records cannot be updated after creation (`allow update: if false`).

---

## 4. Firestore Security Rules Specification (`firestore.rules`)

| Path | Read | Create | Update | Delete |
|---|---|---|---|---|
| `/users/{userId}` | Authenticated | Owner (self) with role `user` | Owner (safe fields) / Admin | Admin only |
| `/users/{userId}/completedActivities/{id}` | Owner / Admin | Owner (schema validated) | **Deny** (Immutable) | Admin only |
| `/users/{userId}/challengeProgress/{id}` | Owner / Admin | Owner | Owner | Admin only |
| `/users/{userId}/unlockedAchievements/{id}` | Owner / Admin | Owner | **Deny** (Immutable) | Admin only |
| `/users/{userId}/notifications/{id}` | Owner / Admin | Owner / Admin | Owner (`isRead` only) | Owner / Admin |
| `/users/{userId}/settings/{id}` | Owner / Admin | Owner | Owner | Owner / Admin |
| `/ecoActivities/{activityId}` | Authenticated | Admin only | Admin only | Admin only |
| `/challenges/{challengeId}` | Authenticated | Admin only | Admin only | Admin only |
| `/achievements/{achievementId}` | Authenticated | Admin only | Admin only | Admin only |
| `/announcements/{announcementId}` | Authenticated | Admin only | Admin only | Admin only |
| `/{document=**}` (All other paths) | **Deny** | **Deny** | **Deny** | **Deny** |

---

## 5. Firebase Storage Security Rules (`storage.rules`)

* **User Profile Images (`/users/{userId}/*`)**:
  - Readable by authenticated users.
  - Writable only by resource owner (`request.auth.uid == userId`).
  - File size restricted to `< 5MB`.
  - MIME type restricted to valid images: `image/(jpeg|jpg|png|webp)`.
* **Administrative Assets (`/assets/*`)**:
  - Readable by authenticated users.
  - Writable and deletable only by verified admins (`isAdmin()`).
* **Default Catch-All**: Disallows arbitrary public uploads (`allow read, write: if false;`).

---

## 6. Input Validation & Error Sanitization

* **Client Validation**: Form validation on `Name`, `Email`, `Password`, and numerical inputs in UI components.
* **Error Sanitization**: `ErrorSanitizer` intercepts technical Firebase errors and translates them into user-friendly messages without exposing database internals, collection names, or stack traces.

---

## 7. Manual Firebase Console Configuration

1. **Deploy Firestore Rules**:
   ```bash
   firebase deploy --only firestore:rules
   ```
2. **Deploy Storage Rules**:
   ```bash
   firebase deploy --only storage
   ```
3. **Assigning Admin Role**:
   - In Firebase Console > Firestore Database > `users` collection.
   - Locate the target user document (`users/{uid}`).
   - Set field `role: "admin"`.
