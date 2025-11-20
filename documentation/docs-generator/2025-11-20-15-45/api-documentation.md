# API Documentation

This document describes the Firestore service APIs used by the Boulder League App. Since the app uses Firebase Firestore directly (not REST APIs), this documentation follows a Swagger-style format adapted for Firestore operations.

---

## Authentication Service

### Login

**Method:** Firebase Auth
**Operation:** `signInWithEmailAndPassword`

#### Description
Authenticates a user with email and password credentials.

#### Request
```dart
{
  "email": "string",
  "password": "string"
}
```

#### Response
```dart
BaseReturnObject {
  "success": bool,
  "message": "string"
}
```

#### Status Codes
- **Success**: Login successful
- **Error**: Invalid credentials, user not found, etc.

---

### Create Account

**Method:** Firebase Auth
**Operation:** `createUserWithEmailAndPassword`

#### Description
Creates a new user account with optional username, sends verification email.

#### Request
```dart
{
  "username": "string?",
  "email": "string",
  "password": "string"
}
```

#### Response
```dart
BaseReturnObject {
  "success": bool,
  "message": "string"
}
```

#### Status Codes
- **Success**: Account created successfully
- **Error**: Email already in use, weak password, etc.

---

### Logout

**Method:** Firebase Auth
**Operation:** `signOut`

#### Description
Signs out the current user.

#### Request
None

#### Response
```dart
BaseReturnObject {
  "success": bool,
  "message": "string"
}
```

---

### Update Username

**Method:** Firebase Auth
**Operation:** `updateDisplayName`

#### Description
Updates the display name for the current user.

#### Request
```dart
{
  "username": "string"
}
```

#### Response
```dart
BaseReturnObject {
  "success": bool,
  "message": "string"
}
```

---

### Update Email

**Method:** Firebase Auth
**Operation:** `verifyBeforeUpdateEmail`

#### Description
Sends verification email before updating user's email address.

#### Request
```dart
{
  "email": "string"
}
```

#### Response
```dart
BaseReturnObject {
  "success": bool,
  "message": "string"
}
```

---

### Update Password

**Method:** Firebase Auth
**Operation:** `reauthenticateWithCredential` + `updatePassword`

#### Description
Updates user password after re-authentication.

#### Request
```dart
{
  "currentPassword": "string",
  "newPassword": "string"
}
```

#### Response
```dart
BaseReturnObject {
  "success": bool,
  "message": "string"
}
```

---

### Send Password Reset

**Method:** Firebase Auth
**Operation:** `sendPasswordResetEmail`

#### Description
Sends a password reset email to the specified address.

#### Request
```dart
{
  "email": "string"
}
```

#### Response
```dart
BaseReturnObject {
  "success": bool,
  "message": "string"
}
```

---

## Gym Service

**Collection:** `gyms`

### Data Model

```dart
Gym {
  "id": "string",           // Document ID (auto-generated)
  "name": "string",         // Gym name (unique)
  "activeSeasonId": "string?", // Currently active season
  "baseMetaData": {
    "createdAt": "Timestamp",
    "updatedAt": "Timestamp",
    "createdBy": "string"
  }
}
```

---

### Add Gym

**Operation:** `collection.add()`

#### Description
Creates a new gym. Validates that gym name is unique.

#### Request
```dart
Gym {
  "name": "string",
  "activeSeasonId": "string?",
  "baseMetaData": BaseMetaData
}
```

#### Response
```dart
BaseReturnObject {
  "success": bool,
  "message": "string"
}
```

#### Validation
- Gym name must be unique across all gyms

#### Status Codes
- **Success**: Gym created successfully
- **Error**: A gym with that name already exists

---

### Update Gym

**Operation:** `collection.doc(id).set()`

#### Description
Updates an existing gym. Validates name uniqueness excluding current gym.

#### Request
```dart
Gym {
  "id": "string",           // Required for update
  "name": "string",
  "activeSeasonId": "string?",
  "baseMetaData": BaseMetaData
}
```

#### Response
```dart
BaseReturnObject {
  "success": bool,
  "message": "string"
}
```

---

### Get Gyms

**Operation:** `collection.snapshots()`

#### Description
Returns a real-time stream of all gyms, ordered by name.

#### Request
None

#### Response
```dart
Stream<List<Gym>>
```

---

## Season Service

**Collection:** `seasons`

### Data Model

```dart
Season {
  "id": "string",           // Document ID
  "gymId": "string",        // Reference to gym
  "name": "string",         // Season name (unique per gym)
  "startDate": "Timestamp", // Season start date
  "endDate": "Timestamp",   // Season end date
  "baseMetaData": BaseMetaData
}
```

---

### Add Season

**Operation:** `collection.add()`

#### Description
Creates a new season for a gym. Validates name uniqueness within gym.

#### Request
```dart
Season {
  "gymId": "string",
  "name": "string",
  "startDate": "DateTime",
  "endDate": "DateTime",
  "baseMetaData": BaseMetaData
}
```

#### Response
```dart
BaseReturnObject {
  "success": bool,
  "message": "string"
}
```

#### Validation
- Season name must be unique within the same gym

---

### Update Season

**Operation:** `collection.doc(id).set()`

#### Description
Updates an existing season.

#### Request
```dart
Season {
  "id": "string",
  "gymId": "string",
  "name": "string",
  "startDate": "DateTime",
  "endDate": "DateTime",
  "baseMetaData": BaseMetaData
}
```

#### Response
```dart
BaseReturnObject {
  "success": bool,
  "message": "string"
}
```

---

### Get Seasons

**Operation:** `collection.snapshots()`

#### Description
Returns a real-time stream of seasons with optional filters.

#### Request (Filters)
```dart
SeasonFilters {
  "gymId": "string?",
  "startDate": "DateTime?",
  "endDate": "DateTime?"
}
```

#### Response
```dart
Stream<List<Season>>
```

---

## Boulder Service

**Collection:** `boulders`

### Data Model

```dart
Boulder {
  "id": "string",           // Document ID
  "gymId": "string",        // Reference to gym
  "name": "string",         // Boulder name
  "seasonId": "string",     // Reference to season
  "week": "num",            // Week number
  "baseMetaData": BaseMetaData
}
```

---

### Add Boulder

**Operation:** `collection.add()`

#### Description
Creates a new boulder. Validates uniqueness of name within gym/season/week combination.

#### Request
```dart
Boulder {
  "gymId": "string",
  "name": "string",
  "seasonId": "string",
  "week": "num",
  "baseMetaData": BaseMetaData
}
```

#### Response
```dart
BaseReturnObject {
  "success": bool,
  "message": "string"
}
```

#### Validation
- Boulder name must be unique within same gym, season, and week

---

### Update Boulder

**Operation:** `collection.doc(id).set()`

#### Description
Updates an existing boulder.

#### Request
```dart
Boulder {
  "id": "string",
  "gymId": "string",
  "name": "string",
  "seasonId": "string",
  "week": "num",
  "baseMetaData": BaseMetaData
}
```

#### Response
```dart
BaseReturnObject {
  "success": bool,
  "message": "string"
}
```

---

### Get Boulders

**Operation:** `collection.snapshots()`

#### Description
Returns a real-time stream of boulders with optional filters, ordered by name.

#### Request (Filters)
```dart
BoulderFilters {
  "gymId": "string?",
  "seasonId": "string?",
  "week": "num?"
}
```

#### Response
```dart
Stream<List<Boulder>>
```

---

## Scoring Service

**Collection:** `scores`

### Data Model

```dart
ScoredBoulder {
  "id": "string",           // Document ID
  "uid": "string",          // User ID
  "boulderId": "string",    // Reference to boulder
  "gymId": "string",        // Reference to gym
  "seasonId": "string",     // Reference to season
  "week": "num",            // Week number
  "attempts": "num",        // Number of attempts
  "completed": "bool",      // Completion status
  "score": "num",           // Calculated score
  "displayName": "string?", // User display name
  "baseMetaData": BaseMetaData
}
```

---

### Add Score

**Operation:** `collection.add()`

#### Description
Records a score for a boulder. One score per user per boulder.

#### Request
```dart
ScoredBoulder {
  "uid": "string",
  "boulderId": "string",
  "gymId": "string",
  "seasonId": "string",
  "week": "num",
  "attempts": "num",
  "completed": "bool",
  "score": "num",
  "displayName": "string?",
  "baseMetaData": BaseMetaData
}
```

#### Response
```dart
BaseReturnObject {
  "success": bool,
  "message": "string"
}
```

#### Validation
- One score per user per boulder (unique uid + boulderId)

#### Score Calculation
```dart
if (completed) {
  score = 100;
  if (attempts == 1) {
    score += 25;  // Flash bonus
  } else {
    score -= attempts * 0.1;  // Attempt penalty
  }
} else {
  score = 0;
}
```

---

### Update Score

**Operation:** `collection.doc(id).set()`

#### Description
Updates an existing score record.

#### Request
```dart
ScoredBoulder {
  "id": "string",
  // ... all other fields
}
```

#### Response
```dart
BaseReturnObject {
  "success": bool,
  "message": "string"
}
```

---

### Get Scores

**Operation:** `collection.snapshots()`

#### Description
Returns a real-time stream of scores with optional filters.

#### Request (Filters)
```dart
ScoredBoulderFilters {
  "gymId": "string?",
  "boulderId": "string?",
  "seasonId": "string?",
  "week": "num?",
  "uid": "string?"
}
```

#### Response
```dart
Stream<List<ScoredBoulder>>
```

---

## Common Data Types

### BaseReturnObject

Standard return type for all service operations.

```dart
BaseReturnObject {
  "success": bool,    // Operation success status
  "message": "string" // Human-readable message
}
```

### BaseMetaData

Audit metadata included in all entities.

```dart
BaseMetaData {
  "createdAt": "Timestamp",  // Creation timestamp
  "updatedAt": "Timestamp",  // Last update timestamp
  "createdBy": "string"      // User ID of creator
}
```

### LeaderboardEntry

Aggregated score entry for leaderboard display.

```dart
LeaderboardEntry {
  "uid": "string",          // User ID
  "totalScore": "num",      // Sum of all scores
  "displayName": "string?"  // User display name
}
```

---

## Firestore Collections Summary

| Collection | Primary Key | Unique Constraints |
|------------|-------------|-------------------|
| `gyms` | Auto ID | name |
| `seasons` | Auto ID | gymId + name |
| `boulders` | Auto ID | gymId + seasonId + week + name |
| `scores` | Auto ID | boulderId + uid |

---

## Error Handling

All service methods return `BaseReturnObject` with consistent error handling:

1. **Success**: `success: true` with descriptive message
2. **Firebase Auth Error**: Extracts Firebase error message
3. **Validation Error**: Custom message for business rule violations
4. **Unknown Error**: Generic error message or error.toString()

---
*Generated by docs-generator agent on 2025-11-20 15:45*
