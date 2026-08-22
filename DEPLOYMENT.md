# EcoTrack Backend & Cloud Deployment Guide

This guide details the production deployment, infrastructure configuration, security rule deployment, indexing, and backup strategy for the EcoTrack platform.

---

## 1. Firebase Project Specifications

* **Project Name**: EcoTrack
* **Project ID**: `ecotrack-100ff`
* **Project Number**: `252310574246`
* **Region**: `us-central1` (or user-selected multi-region)
* **Configuration Mapping**: Generated in [`lib/firebase_options.dart`](file:///c:/Users/USER/Documents/GitHub/EcoTrack/lib/firebase_options.dart)

---

## 2. Infrastructure Deployment Commands

All deployment definitions are unified in [`firebase.json`](file:///c:/Users/USER/Documents/GitHub/EcoTrack/firebase.json).

### A. Deploy Cloud Firestore Rules & Indexes
```bash
firebase deploy --only firestore
```
* **Rules File**: [`firestore.rules`](file:///c:/Users/USER/Documents/GitHub/EcoTrack/firestore.rules)
* **Indexes File**: [`firestore.indexes.json`](file:///c:/Users/USER/Documents/GitHub/EcoTrack/firestore.indexes.json)

### B. Deploy Firebase Storage Security Rules
```bash
firebase deploy --only storage
```
* **Rules File**: [`storage.rules`](file:///c:/Users/USER/Documents/GitHub/EcoTrack/storage.rules)

### C. Deploy All Backend Components Together
```bash
firebase deploy --only firestore,storage
```

---

## 3. Production Firestore Schema & Security Summary

| Collection | Schema / Path | Access Model |
|---|---|---|
| `users` | `users/{userId}` | Read: Authenticated. Write: Owner (non-sensitive profile fields) / Admin. |
| `completedActivities` | `users/{userId}/completedActivities/{id}` | Read: Owner / Admin. Create: Owner (validated). Update: **Denied** (Immutable). |
| `challengeProgress` | `users/{userId}/challengeProgress/{id}` | Read: Owner / Admin. Write: Owner (validated progress). |
| `unlockedAchievements` | `users/{userId}/unlockedAchievements/{id}` | Read: Owner / Admin. Create: Owner. Update: **Denied** (Immutable). |
| `notifications` | `users/{userId}/notifications/{id}` | Read: Owner. Update: Owner (`isRead` only). Create/Delete: Owner / Admin. |
| `ecoActivities` | `ecoActivities/{activityId}` | Read: Authenticated. Write: **Admin only**. |
| `challenges` | `challenges/{challengeId}` | Read: Authenticated. Write: **Admin only**. |
| `achievements` | `achievements/{achievementId}` | Read: Authenticated. Write: **Admin only**. |
| `announcements` | `announcements/{announcementId}` | Read: Authenticated. Write: **Admin only**. |

---

## 4. Production Database Seeding (Admin Console)

To seed initial production content without using hardcoded or mock client data:
1. Authenticate with your administrative account in the mobile app.
2. Navigate to **Admin Console** (`/admin`).
3. Use the respective management consoles to create initial content:
   - **Manage Activities**: Create verified daily eco-friendly actions (e.g., Tree Planting, Composting, Bicycle Commute, Reusable Water Bottle).
   - **Manage Challenges**: Define weekly/monthly community challenges.
   - **Manage Achievements**: Configure tiered badge requirements.
   - **System Announcements**: Publish welcome and kick-off broadcasts.

---

## 5. Monitoring, Logging & Error Tracking

* **Firestore Usage & Rules Monitoring**:
  - In Firebase Console > Firestore Database > **Usage** and **Rules** tabs.
  - Monitor read/write operations and rule denials.
* **Authentication Monitoring**:
  - In Firebase Console > Authentication > **Users** tab.
  - Inspect sign-in methods, user creation dates, and disable suspicious accounts.
* **Storage Monitoring**:
  - In Firebase Console > Storage > **Usage** tab.
  - Validate that uploaded avatars adhere to `< 5MB` constraints.

---

## 6. Backup & Disaster Recovery Strategy

1. **Automated Scheduled Backups**:
   - Configure Cloud Firestore Managed Export using Google Cloud Console / Cloud Scheduler:
   ```bash
   gcloud firestore export gs://[BACKUP_BUCKET_NAME] --project=ecotrack-100ff
   ```
2. **Point-In-Time Recovery (PITR)**:
   - Enable PITR on Cloud Firestore in the Google Cloud Console for continuous 7-day data protection.
3. **Restoration Command**:
   ```bash
   gcloud firestore import gs://[BACKUP_BUCKET_NAME]/[EXPORT_PREFIX] --project=ecotrack-100ff
   ```

---

## 7. Secrets & Credential Protection

* **Client Keys vs Server Secrets**:
  - Firebase API keys in `firebase_options.dart` and `google-services.json` are client identifiers and restricted by Firestore/Storage Security Rules.
  - Private service account keys and signing keystores are strictly excluded via [`.gitignore`](file:///c:/Users/USER/Documents/GitHub/EcoTrack/.gitignore).
