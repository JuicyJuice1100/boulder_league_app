# Boulder League App - Main Context for AI Agents

**Version:** 1.1.0
**Last Updated:** November 20, 2025
**Project:** Boulder Climbing League Management Application

> **Documentation:** For detailed UML diagrams and API documentation, see [documentation/docs-generator/2025-11-20-15-45](../documentation/docs-generator/2025-11-20-15-45/README.md)

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Technology Stack](#2-technology-stack)
3. [Development Environment Setup](#3-development-environment-setup)
4. [Docker Containerization](#4-docker-containerization)
5. [Folder Structure](#5-folder-structure)
6. [Data Models & Types](#6-data-models--types)
7. [Services Architecture](#7-services-architecture)
8. [UI Components Architecture](#8-ui-components-architecture)
9. [Screens & Routing](#9-screens--routing)
10. [Firebase Integration](#10-firebase-integration)
11. [Service Flow Diagrams](#11-service-flow-diagrams)
12. [Testing Configuration](#12-testing-configuration)
13. [Build & Deployment](#13-build--deployment)

---

## 1. Project Overview

The **Boulder League App** is a Flutter-based web and mobile application designed to manage climbing boulder leagues. It enables:

- **Gym Management**: Create and manage climbing gyms
- **Season Management**: Define competition seasons with date ranges
- **Boulder Management**: Track individual boulder problems by week and season
- **Scoring System**: Record user attempts and calculate scores
- **Leaderboards**: Real-time rankings for each season/gym combination
- **User Authentication**: Email/password authentication via Firebase Auth

**Core Entities:**
- Gyms → Seasons → Boulders → Scored Boulders → Leaderboards

---

## 2. Technology Stack

### Frontend Framework
- **Flutter SDK**: ^3.7.0 (Dart language)
- **Platform Support**: Web, iOS, Android
- **UI Library**: Material Design (MaterialApp)

### Backend & Database
- **Firebase Core**: ^4.2.0
- **Firebase Authentication**: ^6.1.1 (email/password)
- **Cloud Firestore**: ^6.0.3 (NoSQL database with real-time sync)

### Key Dependencies

```yaml
dependencies:
  # Firebase
  firebase_core: ^4.2.0
  firebase_auth: ^6.1.1
  cloud_firestore: ^6.0.3

  # Form & Validation
  flutter_form_builder: ^10.0.1
  form_builder_validators: ^11.1.2

  # UI/UX
  cupertino_icons: ^1.0.8
  toastification: ^3.0.2

  # Utilities
  uuid: ^4.5.1
  intl: ^0.20.2
  dartx: ^1.2.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
```

### Emulators & Testing
- **Firebase Emulator Suite**: Auth (port 9099), Firestore (port 8080), UI (port 4000)
- **Node.js**: v25.0.0 (for Firebase CLI)
- **Java**: OpenJDK 25 (for Firebase emulators)

### Containerization
- **Docker**: Multi-container setup with docker-compose
- **Nginx**: Web server and reverse proxy

---

## 3. Development Environment Setup

### Local Development (Without Docker)

#### Prerequisites
```bash
# Required installations
- Flutter SDK (latest stable)
- Node.js v25.0.0+
- Java OpenJDK 25+
- Firebase CLI
```

#### Installation Steps

1. **Install Flutter**
```bash
# Download from flutter.dev
export PATH="$PATH:[PATH_TO_FLUTTER]/flutter/bin"
flutter doctor
```

2. **Install Firebase CLI**
```bash
curl -sL https://firebase.tools | bash
firebase --version
```

3. **Install Dependencies**
```bash
flutter pub get
```

4. **Start Firebase Emulators**
```bash
firebase emulators:start --import ./default-test-data
```

Access emulator UI at: `http://localhost:4000`

5. **Run Flutter App**
```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device-id>

# Run on web
flutter run -d chrome

# Run on iOS simulator (macOS only)
flutter run -d ios

# Run on Android emulator
flutter run -d android
```

### Emulator Configuration

**Default Emulator Ports:**
- Firestore: `localhost:8080`
- Auth: `localhost:9099`
- UI: `localhost:4000`

**Environment Detection:**
- Debug mode (`kDebugMode`): Automatically uses emulators
- Production mode: Connects to live Firebase (if `USE_EMULATOR=false`)

---

## 4. Docker Containerization

### Architecture Overview

The Docker setup uses a **3-container architecture**:

```
┌─────────────────────┐
│  boulder_league_web │  (Port 8000)
│  Flutter Web App    │
└──────────┬──────────┘
           │ Connects to localhost:8080, localhost:9099
           │
┌──────────┴────────────────────┐
│                               │
│  ┌─────────────────────────┐ │
│  │ boulder_league_firebase │ │  (Ports 8080, 9099)
│  │ Auth + Firestore        │ │
│  └──────────┬──────────────┘ │
│             │                 │
│  ┌──────────┴──────────────┐ │
│  │ boulder_league_firebase_│ │  (Port 4000)
│  │ proxy (Nginx)           │ │
│  └─────────────────────────┘ │
└───────────────────────────────┘
```

### Docker Files Location

All Docker files are in `.docker/` directory:

```
.docker/
├── docker-compose.yml      # Orchestrates all services
├── Dockerfile              # Web app build
├── Dockerfile.firebase     # Firebase emulators
├── Dockerfile.proxy        # Nginx proxy for emulator UI
├── nginx.conf              # Web app nginx config
└── nginx.proxy.conf        # Proxy nginx config
```

### Container Details

#### 1. **boulder_league_web** (Flutter Web App)

**Dockerfile:** `.docker/Dockerfile`

**Build Process:**
- Stage 1: Build Flutter web app using `ghcr.io/cirruslabs/flutter:stable`
- Stage 2: Serve with `nginx:alpine`

**Build Arguments:**
```dockerfile
ARG USE_EMULATOR=true
ARG FIRESTORE_HOST=localhost
ARG FIRESTORE_PORT=8080
ARG AUTH_HOST=localhost
ARG AUTH_PORT=9099
```

**Key Features:**
- Multi-stage build (reduces final image size)
- Compiled to static web files
- Gzip compression enabled
- Security headers configured
- Cache control for static assets (1 year)
- No-cache for index.html

**Port Mapping:** `8000:80`

#### 2. **boulder_league_firebase** (Emulators)

**Dockerfile:** `.docker/Dockerfile.firebase`

**Base Image:** `node:20-alpine`

**Installed Components:**
- OpenJDK 21 LTS (required for emulators)
- Firebase CLI (via npm)
- curl (for healthchecks)

**Emulator Services:**
- Firestore: Port 8080
- Auth: Port 9099
- UI: Port 4000

**Startup Command:**
```bash
firebase emulators:start \
  --import ./default-test-data \
  --project boulder-league-app \
  --only auth,firestore
```

**Data Persistence:**
- Volume: `firebase-data` → `/firebase/.cache/firebase/emulators`

**Healthcheck:**
```yaml
test: ["CMD", "curl", "-f", "http://localhost:4000"]
interval: 30s
timeout: 10s
retries: 5
start_period: 40s
```

#### 3. **boulder_league_firebase_proxy** (Nginx Proxy)

**Dockerfile:** `.docker/Dockerfile.proxy`

**Base Image:** `nginx:alpine`

**Purpose:**
- Provides access to Firebase Emulator UI
- Routes traffic between web app and emulators

**Routing Rules:**
- `/` → Firebase UI (port 4000)
- `/v1/*`, `/google.firestore.*` → Firestore API (port 8080)
- `/identitytoolkit/*`, `/securetoken/*` → Auth API (port 9099)
- `/health` → Healthcheck endpoint

**Key Features:**
- WebSocket support (for real-time Firestore)
- Increased timeouts (300s)
- Proxy headers configuration

**Port Mapping:** `4000:80`

### Docker Compose Configuration

**File:** `.docker/docker-compose.yml`

**Environment Variables (.env.local):**
```env
# Emulator Configuration
USE_EMULATOR=true
FIRESTORE_HOST=localhost
FIRESTORE_PORT=8080
AUTH_HOST=localhost
AUTH_PORT=9099

# Port Mappings
WEB_PORT=8000
FIREBASE_UI_PORT=4000
```

**Service Dependencies:**
```
web → firebase-proxy → firebase
```

**Network:**
- `boulder_league_network` (bridge driver)
- Enables inter-container communication

### Running with Docker

#### Start All Services
```bash
# From project root
docker-compose -f .docker/docker-compose.yml up --build

# Or with alias
alias dc='docker-compose -f .docker/docker-compose.yml'
dc up --build
```

#### Access Points
- Web App: `http://localhost:8000`
- Firebase UI: `http://localhost:4000`
- Firestore Emulator: `localhost:8080`
- Auth Emulator: `localhost:9099`

#### Individual Services
```bash
# Run only web app
dc up web

# Run only Firebase emulators
dc up firebase

# Run Firebase with proxy
dc up firebase firebase-proxy
```

#### Stop Services
```bash
# Stop all
dc down

# Stop and remove volumes
dc down -v
```

### Production Build (Without Emulators)

```bash
docker build \
  --build-arg USE_EMULATOR=false \
  -f .docker/Dockerfile \
  -t boulder-league-app:latest .

docker run -p 8000:80 boulder-league-app:latest
```

---

## 5. Folder Structure

### Root Directory
```
boulder_league_app/
├── .docker/                  # Docker configuration files
├── android/                  # Android platform files
├── ios/                      # iOS platform files
├── web/                      # Web platform files
├── lib/                      # Main Dart source code
├── integration_test/         # Integration tests (helpers & services)
├── default-test-data/        # Firebase emulator seed data
├── firebase.json             # Firebase configuration
├── firestore.rules           # Firestore security rules
├── firestore.indexes.json    # Firestore indexes
├── pubspec.yaml              # Flutter dependencies
└── README.md                 # Documentation
```

### lib/ Directory Structure

```
lib/
├── main.dart                 # App entry point & initialization
├── firebase_options.dart     # Generated Firebase config
├── env_config.dart           # Environment configuration
├── app_global.dart           # Global constants (navigatorKey)
├── auth_provider.dart        # AuthService InheritedWidget
│
├── models/                   # Data models
│   ├── base_meta_data.dart           # Audit metadata
│   ├── base_return_object.dart       # Service return wrapper
│   ├── boulder.dart                  # Boulder entity
│   ├── boulder_filters.dart          # Boulder query filters
│   ├── gym.dart                      # Gym entity
│   ├── leaderboard_entry.dart        # Leaderboard entry
│   ├── scored_boulder.dart           # User score entity
│   ├── scored_boulder_filters.dart   # Score query filters
│   ├── season.dart                   # Season entity
│   └── season_filters.dart           # Season query filters
│
├── services/                 # Firebase service layer
│   ├── auth_service.dart             # Authentication operations
│   ├── boulder_service.dart          # Boulder CRUD
│   ├── gym_service.dart              # Gym CRUD
│   ├── scoring_service.dart          # Scored boulder CRUD
│   └── season_service.dart           # Season CRUD
│
├── screens/                  # Full-page screens
│   ├── home.dart                     # Main app (tabbed interface)
│   ├── login.dart                    # Login screen
│   ├── signup.dart                   # Registration screen
│   ├── account.dart                  # Account management (disabled)
│   └── user.dart                     # User profile widget
│
├── components/               # Reusable UI components
│   ├── section.dart                  # Base section container
│   │
│   ├── boulders/
│   │   ├── boulders_section.dart     # Boulder feature container
│   │   ├── boulders_filters.dart     # Filter dropdowns
│   │   ├── boulders_form.dart        # Create/edit form
│   │   └── boulders_table.dart       # Data table
│   │
│   ├── gyms/
│   │   ├── gyms_section.dart         # Gym feature container
│   │   ├── gyms_form.dart            # Create/edit form
│   │   └── gyms_table.dart           # Data table
│   │
│   ├── leaderboards/
│   │   ├── leaderboard_section.dart  # Leaderboard container
│   │   ├── leaderboard_filters.dart  # Filter dropdowns
│   │   └── leaderboard_table.dart    # Ranked table
│   │
│   ├── scores/
│   │   ├── scores_section.dart       # Score feature container
│   │   ├── scores_filters.dart       # Filter dropdowns
│   │   ├── scores_form.dart          # Create/edit form
│   │   └── scores_table.dart         # Data table
│   │
│   ├── seasons/
│   │   ├── seasons_section.dart      # Season feature container
│   │   ├── seasons_filters.dart      # Filter dropdowns
│   │   ├── seasons_form.dart         # Create/edit form
│   │   └── seasons_table.dart        # Data table
│   │
│   ├── login_card.dart               # Login form component
│   ├── sign_up_card.dart             # Signup form component
│   ├── update_username_card.dart     # Username update form
│   ├── update_email_card.dart        # Email update form
│   └── update_password_card.dart     # Password update form
│
├── helpers/                  # Utility functions
│   ├── score_calculator.dart         # Score calculation logic
│   └── toast_notification.dart       # Toast notification helpers
│
└── static/                   # Static data & constants
    ├── weeks.dart                    # Week list (1-12)
    ├── default_boulder_filters.dart  # Default boulder filters
    ├── default_scored_boulder_filters.dart
    └── default_season_filters.dart
```

---

## 6. Data Models & Types

### BaseMetaData
**File:** `lib/models/base_meta_data.dart`

Audit metadata embedded in all main entities.

```dart
class BaseMetaData {
  final String createdByUid;
  final String lastUpdateByUid;
  final DateTime createdAt;        // Stored as Firestore Timestamp
  final DateTime lastUpdateAt;     // Stored as Firestore Timestamp
}
```

**Usage:** Tracks who created/modified records and when.

---

### Boulder
**File:** `lib/models/boulder.dart`

Represents a climbing boulder problem.

```dart
class Boulder {
  final String id;                 // UUID (Firestore document ID)
  final String gymId;              // Reference to Gym
  final String name;               // Boulder identifier/name
  final num week;                  // Week number (1-12)
  final String seasonId;           // Reference to Season
  final BaseMetaData baseMetaData;
}
```

**Firestore Collection:** `boulders`

**Indexes:**
- `gymId`, `seasonId`, `week` (composite for filtering)

---

### Season
**File:** `lib/models/season.dart`

Represents a competition season.

```dart
class Season {
  final String id;                 // UUID
  final String gymId;              // Reference to Gym
  final String name;               // Season name (e.g., "Spring 2024")
  final DateTime startDate;        // Season start
  final DateTime endDate;          // Season end
  final BaseMetaData baseMetaData;
}
```

**Firestore Collection:** `seasons`

**Indexes:**
- `gymId` (for filtering seasons by gym)

---

### Gym
**File:** `lib/models/gym.dart`

Represents a climbing gym.

```dart
class Gym {
  final String id;                 // UUID
  final String name;               // Gym name
  final String? activeSeasonId;    // Optional reference to active Season
  final BaseMetaData baseMetaData;
}
```

**Firestore Collection:** `gyms`

**Note:** `activeSeasonId` used for auto-selecting season in leaderboard.

---

### ScoredBoulder
**File:** `lib/models/scored_boulder.dart`

Represents a user's attempt/completion of a boulder.

```dart
class ScoredBoulder {
  final String id;                 // UUID
  final String uid;                // Firebase Auth UID
  final String boulderId;          // Reference to Boulder
  final String gymId;              // Reference to Gym
  final String seasonId;           // Reference to Season
  final num week;                  // Week number
  final num attempts;              // Number of attempts
  final bool completed;            // Successfully completed?
  final num score;                 // Calculated score
  final String? displayName;       // Cached user displayName
  final BaseMetaData baseMetaData;
}
```

**Firestore Collection:** `scores`

**Indexes:**
- `uid`, `seasonId`, `gymId` (composite for leaderboard queries)
- `boulderId`, `uid` (composite for duplicate checking)

**Score Calculation:**
- Completed: 100 + (attempts == 1 ? 25 : -attempts * 0.1)
- Not completed: 0

**Examples:**
- First attempt completion: 100 + 25 = 125 points
- 3 attempts completion: 100 - 0.3 = 99.7 points
- Failed (any attempts): 0 points

---

### LeaderboardEntry
**File:** `lib/models/leaderboard_entry.dart`

Aggregated user score for leaderboard display.

```dart
class LeaderboardEntry {
  final String uid;
  final num totalScore;            // Sum of all scores
  final String? displayName;

  String get userName => displayName ?? uid;
}
```

**Note:** Not stored in Firestore - computed client-side from ScoredBoulder list.

---

### Filter Objects

#### BoulderFilters
```dart
class BoulderFilters {
  final String? gymId;
  final String? seasonId;
  final num? week;
}
```

#### SeasonFilters
```dart
class SeasonFilters {
  final String? gymId;
  final DateTime? startDate;
  final DateTime? endDate;
}
```

#### ScoredBoulderFilters
```dart
class ScoredBoulderFilters {
  final String? gymId;
  final String? seasonId;
  final num? week;
  final String? boulderId;
  final String? uid;
}
```

---

### BaseReturnObject
**File:** `lib/models/base_return_object.dart`

Standard return type for all service operations.

```dart
class BaseReturnObject {
  final bool success;              // Operation succeeded?
  final String message;            // Human-readable message
  final dynamic data;              // Optional payload
}
```

**Usage Pattern:**
```dart
BaseReturnObject result = await authService.login(email, password);
if (result.success) {
  // Success: result.message contains success message
} else {
  // Error: result.message contains error description
}
```

---

## 7. Services Architecture

All services follow a consistent pattern:

1. **CRUD Operations:** Return `Future<BaseReturnObject>`
2. **Query Operations:** Return `Stream<List<T>>`
3. **Error Handling:** Try-catch with FirebaseException and generic Exception
4. **Duplicate Checking:** Prevent duplicate names/entries

### AuthService
**File:** `lib/services/auth_service.dart`

Manages Firebase Authentication.

#### Methods

**1. login(String email, String password)**
```dart
Future<BaseReturnObject> login(String email, String password)
```
- Signs in user with email/password
- Returns success with message or error

**2. createAccount(String? username, String email, String password)**
```dart
Future<BaseReturnObject> createAccount(String? username, String email, String password)
```
- Creates new Firebase Auth user
- Updates displayName if username provided
- Sends email verification
- Returns success/error

**3. logout()**
```dart
Future<BaseReturnObject> logout()
```
- Signs out current user
- Returns success/error

**4. updateUsername(String username)**
```dart
Future<BaseReturnObject> updateUsername(String username)
```
- Updates current user's displayName
- Requires user to be logged in

**5. updateEmail(String email)**
```dart
Future<BaseReturnObject> updateEmail(String email)
```
- Updates user's email with verification
- Requires user to be logged in

**6. updatePassword(String currentPassword, String newPassword)**
```dart
Future<BaseReturnObject> updatePassword(String currentPassword, String newPassword)
```
- Re-authenticates with current password
- Updates to new password

**7. sendPasswordReset(String email)**
```dart
Future<BaseReturnObject> sendPasswordReset(String email)
```
- Sends password reset email

**8. onAuthStateChanged**
```dart
Stream<User?> get onAuthStateChanged
```
- Stream of authentication state
- Used by HomeController to show login/home screen

---

### BoulderService
**File:** `lib/services/boulder_service.dart`

Manages boulder CRUD operations.

**Firestore Collection:** `boulders`

#### Methods

**1. addBoulder(Boulder boulder)**
```dart
Future<BaseReturnObject> addBoulder(Boulder boulder)
```
- Creates new boulder document
- Checks for duplicates: same `gymId`, `name`, `seasonId`, `week`
- Returns error if duplicate found

**2. updateBoulder(Boulder boulder)**
```dart
Future<BaseReturnObject> updateBoulder(Boulder boulder)
```
- Updates existing boulder
- Checks for duplicate names (excluding self)
- Uses `merge: true` for partial updates

**3. getBoulders(BoulderFilters? filters)**
```dart
Stream<List<Boulder>> getBoulders(BoulderFilters? filters)
```
- Returns real-time stream of boulders
- Filters applied:
  - `gymId` → `where('gymId', isEqualTo: gymId)`
  - `seasonId` → `where('seasonId', isEqualTo: seasonId)`
  - `week` → `where('week', isEqualTo: week)`
- Null filters are omitted
- Results sorted by `name` ascending

---

### GymService
**File:** `lib/services/gym_service.dart`

Manages gym CRUD operations.

**Firestore Collection:** `gyms`

#### Methods

**1. addGym(Gym gym)**
```dart
Future<BaseReturnObject> addGym(Gym gym)
```
- Creates new gym document
- Checks for duplicate gym names
- Returns error if duplicate found

**2. updateGym(Gym gym)**
```dart
Future<BaseReturnObject> updateGym(Gym gym)
```
- Updates existing gym
- Checks for duplicate names (excluding self)
- Uses `merge: true`

**3. getGyms()**
```dart
Stream<List<Gym>> getGyms()
```
- Returns real-time stream of all gyms
- No filters applied
- Results sorted by `name` ascending

---

### SeasonService
**File:** `lib/services/season_service.dart`

Manages season CRUD operations.

**Firestore Collection:** `seasons`

#### Methods

**1. addSeason(Season season)**
```dart
Future<BaseReturnObject> addSeason(Season season)
```
- Creates new season document
- Checks for duplicate names (same `gymId` + `name`)
- Returns error if duplicate found

**2. updateSeason(Season season)**
```dart
Future<BaseReturnObject> updateSeason(Season season)
```
- Updates existing season
- Checks for duplicate names (same gym, excluding self)
- Uses `merge: true`

**3. getSeasons(SeasonFilters? filters)**
```dart
Stream<List<Season>> getSeasons(SeasonFilters? filters)
```
- Returns real-time stream of seasons
- Filters applied:
  - `gymId` → `where('gymId', isEqualTo: gymId)`
  - `startDate` → `where('startDate', isGreaterThanOrEqualTo: startDate)`
  - `endDate` → `where('week', isLessThan: endDate)` **[BUG: should be 'endDate']**
- Results sorted by `startDate` descending

---

### ScoringService
**File:** `lib/services/scoring_service.dart`

Manages scored boulder CRUD operations.

**Firestore Collection:** `scores`

#### Methods

**1. addScore(ScoredBoulder scoredBoulder)**
```dart
Future<BaseReturnObject> addScore(ScoredBoulder scoredBoulder)
```
- Creates new score document
- Checks for duplicates: same `boulderId` + `uid`
- Returns error if user already scored this boulder

**2. updateScore(ScoredBoulder scoredBoulder)**
```dart
Future<BaseReturnObject> updateScore(ScoredBoulder scoredBoulder)
```
- Updates existing score
- Checks for duplicates (excluding self)
- Uses `merge: true`

**3. getScores(ScoredBoulderFilters? filters)**
```dart
Stream<List<ScoredBoulder>> getScores(ScoredBoulderFilters? filters)
```
- Returns real-time stream of scores
- Filters applied (all optional):
  - `gymId` → `where('gymId', isEqualTo: gymId)`
  - `boulderId` → `where('boulderId', isEqualTo: boulderId)`
  - `seasonId` → `where('seasonId', isEqualTo: seasonId)`
  - `week` → `where('week', isEqualTo: week)`
  - `uid` → `where('uid', isEqualTo: uid)`
- Multiple filters combine with AND logic
- Results sorted by `displayName` ascending

---

## 8. UI Components Architecture

### Component Hierarchy Pattern

Each feature follows a consistent 4-layer pattern:

```
Section (Stateful Container)
├── Filters (Stateless)
├── Form (Stateful Dialog)
└── Table (Stateful StreamBuilder)
```

### Base Component: SectionWidget
**File:** `lib/components/section.dart`

Generic container for all feature sections.

**Props:**
- `title` (String): Section title for AppBar
- `add` (Widget?): Optional form dialog for creating new entities
- `filters` (Widget?): Optional filter controls
- `table` (Widget): Required data table

**Renders:**
```
AppBar (title)
└── Column
    ├── Card (filters) [if provided]
    └── Card
        ├── Row (Add button) [if add provided]
        └── table
```

---

### Boulders Components

#### BouldersSection
**File:** `lib/components/boulders/boulders_section.dart`

**State Management:**
- `selectedGymId` (String?)
- `selectedSeasonId` (String?)
- `selectedWeek` (num?)
- `availableGyms` (List<Gym>)
- `availableSeasons` (List<Season>)

**Data Flow:**
1. Loads all gyms via `GymService.getGyms()`
2. Loads filtered seasons via `SeasonService.getSeasons(SeasonFilters(gymId: selectedGymId))`
3. Passes filters to `BouldersTable` and `BouldersForm`

#### BouldersFilters
**File:** `lib/components/boulders/boulders_filters.dart`

**Props:**
- `selectedGymId`, `selectedSeasonId`, `selectedWeek`
- `availableGyms`, `availableSeasons`, `availableWeeks`
- Callbacks: `onGymChanged`, `onSeasonChanged`, `onWeekChanged`

**UI:** 3-column dropdown row (Gym | Season | Week)

#### BouldersForm
**File:** `lib/components/boulders/boulders_form.dart`

**Props:**
- `boulder` (Boulder?): If provided, opens in edit mode
- `availableGyms`, `availableSeasons`, `availableWeeks`

**Form Fields:**
1. Gym (Dropdown) - Required
2. Name (Text) - Required
3. Season (Dropdown) - Required
4. Week (Dropdown) - Required

**On Save:**
```dart
if (boulder == null) {
  await BoulderService().addBoulder(newBoulder);
} else {
  await BoulderService().updateBoulder(updatedBoulder);
}
```

#### BouldersTable
**File:** `lib/components/boulders/boulders_table.dart`

**Data Source:** `BoulderService.getBoulders(filters)`

**Columns:**
1. Gym (looked up from gymId)
2. Name
3. Week
4. Season (looked up from seasonId)

**Interactions:**
- Click row → Opens `BouldersForm` in edit mode

---

### Scores Components

#### ScoresSection
**File:** `lib/components/scores/scores_section.dart`

Similar structure to BouldersSection.

**State:** `selectedGymId`, `selectedSeasonId`, `selectedWeek`

#### ScoresFilters
**File:** `lib/components/scores/scores_filters.dart`

**UI:** 3-column dropdown row (Gym | Season | Week)

#### ScoresForm
**File:** `lib/components/scores/scores_form.dart`

**Props:**
- `scoredBoulder` (ScoredBoulder?): For edit mode
- `availableGyms`, `availableSeasons`, `availableWeeks`

**Form Fields:**
1. Season (Dropdown) - Required
2. Week (Dropdown) - Required
3. Boulder (Dropdown - dynamic based on season/week) - Required
4. Attempts (Number) - Required, min: 1
5. Completed (Checkbox)

**Special Logic:**
- Boulder dropdown populates based on selected season + week
- Score calculated via `ScoreCalculator.calculateScore()` before save
- Current user's `uid` and `displayName` auto-populated

**On Save:**
```dart
scoredBoulder.score = ScoreCalculator.calculateScore(
  attempts: scoredBoulder.attempts,
  completed: scoredBoulder.completed
);

if (scoredBoulder.id.isEmpty) {
  await ScoringService().addScore(scoredBoulder);
} else {
  await ScoringService().updateScore(scoredBoulder);
}
```

#### ScoresTable
**File:** `lib/components/scores/scores_table.dart`

**Data Sources:**
- `ScoringService.getScores(filters)` (primary)
- `BoulderService.getBoulders()` (for boulder name lookup)

**Filters:** Only shows current user's scores (`uid == currentUser.uid`)

**Columns:**
1. User / DisplayName
2. Boulder (name)
3. Attempts
4. Completed (✓ or ✗)
5. Score

**Interactions:**
- Click row → Opens `ScoresForm` in edit mode

---

### Seasons Components

#### SeasonsSection
**File:** `lib/components/seasons/seasons_section.dart`

**State:** `selectedGymId`

#### SeasonsFilters
**File:** `lib/components/seasons/seasons_filters.dart`

**UI:** Single dropdown (Gym)

#### SeasonsForm
**File:** `lib/components/seasons/seasons_form.dart`

**Form Fields:**
1. Gym (Dropdown) - Required
2. Name (Text) - Required
3. Date Range (DateRangePickerFormField) - Required

**On Save:**
```dart
Season season = Season(
  gymId: selectedGymId,
  name: name,
  startDate: dateRange.start,
  endDate: dateRange.end,
  ...
);

await SeasonService().addSeason(season);
```

#### SeasonsTable
**File:** `lib/components/seasons/seasons_table.dart`

**Columns:**
1. Gym (name)
2. Name
3. Start Date (formatted: MM/dd/yyyy)
4. End Date (formatted: MM/dd/yyyy)

---

### Gyms Components

#### GymsSection
**File:** `lib/components/gyms/gyms_section.dart`

Simplest section - no filters, just form + table.

#### GymsForm
**File:** `lib/components/gyms/gyms_form.dart`

**Form Fields:**
1. Name (Text) - Required
2. Active Season (Dropdown) - Optional

**Special Logic:**
- Active Season dropdown loads seasons for the current gym (edit mode only)

#### GymsTable
**File:** `lib/components/gyms/gyms_table.dart`

**Columns:**
1. Name

---

### Leaderboards Components

#### LeaderboardSection
**File:** `lib/components/leaderboards/leaderboard_section.dart`

**State:** `selectedGymId`, `selectedSeasonId`

**Special Logic:**
- Auto-selects gym's `activeSeasonId` if available
- Filters out duplicate seasons in dropdown

#### LeaderboardFilters
**File:** `lib/components/leaderboards/leaderboard_filters.dart`

**UI:** 2-column dropdown row (Gym | Season)

#### LeaderboardTable
**File:** `lib/components/leaderboards/leaderboard_table.dart`

**Data Source:** `ScoringService.getScores(ScoredBoulderFilters(seasonId: selectedSeasonId))`

**Data Processing:**
1. Groups scores by `uid`
2. Sums `totalScore` for each user
3. Creates `LeaderboardEntry` objects
4. Sorts by `totalScore` descending

**Columns:**
1. Rank (1, 2, 3, ...)
2. Username (displayName or uid)
3. Total Score

**Note:** Only populates when `seasonId` is selected.

---

### Auth Components

#### LoginCardForm
**File:** `lib/components/login_card.dart`

**Fields:**
- Email (required, email validator)
- Password (required)

**On Submit:**
```dart
BaseReturnObject result = await authService.login(email, password);
if (result.success) {
  Navigator.pushReplacementNamed(context, '/');
} else {
  ToastNotification.error(result.message);
}
```

#### SignUpCardForm
**File:** `lib/components/sign_up_card.dart`

**Fields:**
- Username (optional)
- Email (required, email validator)
- Password (required, min 6 chars)
- Confirm Password (must match password)

**On Submit:**
```dart
if (password != confirmPassword) {
  ToastNotification.error("Passwords do not match");
  return;
}

BaseReturnObject result = await authService.createAccount(username, email, password);
if (result.success) {
  Navigator.pushReplacementNamed(context, LoginScreen.routeName);
}
```

---

## 9. Screens & Routing

### App Routes

```dart
MaterialApp(
  navigatorKey: AppGlobal.navigatorKey,
  initialRoute: '/',
  routes: {
    '/': (context) => HomeController(),
    '/login': (context) => LoginScreen(),
    '/signup': (context) => SignUpScreen(),
    '/account': (context) => AccountScreen(),
  }
)
```

### HomeController
**File:** `lib/screens/home.dart` (HomeController widget)

**Purpose:** Authentication gate

```dart
StreamBuilder(
  stream: authService.onAuthStateChanged,
  builder: (context, snapshot) {
    if (signedIn) return HomeScreen();
    return LoginScreen();
  }
)
```

### HomeScreen
**File:** `lib/screens/home.dart`

**Layout:** Scaffold with BottomNavigationBar

**Tabs (5 total):**
1. **Leaderboard** (index 0) - LeaderboardSection
2. **Scores** (index 1) - ScoresSection
3. **Boulders** (index 2) - BouldersSection
4. **Seasons** (index 3) - SeasonsSection
5. **Gyms** (index 4) - GymsSection

**AppBar:**
- Title: "Boulder League"
- Drawer menu:
  - UserScreen (shows current user info)
  - Logout button

**Bottom Navigation:**
- Icons: EmojiEvents, ScoreboardOutlined, Terrain, CalendarMonth, FitnessCenter
- Labels: Leaderboard, Scores, Boulders, Seasons, Gyms

### LoginScreen
**File:** `lib/screens/login.dart`

**Route:** `/login`

**Layout:**
- AppBar: "Login"
- Body: LoginCardForm
- Link to SignUpScreen

### SignUpScreen
**File:** `lib/screens/signup.dart`

**Route:** `/signup`

**Layout:**
- AppBar: "Sign Up"
- Body: SignUpCardForm
- Link to LoginScreen

### AccountScreen
**File:** `lib/screens/account.dart`

**Route:** `/account`

**Status:** Currently disabled (not linked from HomeScreen)

**Layout:**
- UpdateUsernameCardForm
- UpdateEmailCardForm
- UpdatePasswordCardForm

### UserScreen
**File:** `lib/screens/user.dart`

**Usage:** Displayed in HomeScreen drawer

**Data Source:** `FirebaseAuth.instance.authStateChanges()`

**Display:**
- Username (displayName)
- Email

---

## 10. Firebase Integration

### Firebase Project Configuration

**Project ID:** `boulder-league-app`

**Platforms:**
- Android: `1:822562274761:android:a71a7fd2d78c1eb20bfc18`
- iOS: `1:822562274761:ios:706e6c2e76bb93da0bfc18`
- Web: `1:822562274761:web:ac858e4b45edf05b0bfc18`

**Configuration File:** `lib/firebase_options.dart` (auto-generated)

### Firebase Initialization

**File:** `lib/main.dart`

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Enable offline persistence
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true
  );

  // Configure emulators if in debug mode
  final bool shouldUseEmulator = EnvConfig.useEmulator || kDebugMode;

  if (shouldUseEmulator) {
    FirebaseFirestore.instance.useFirestoreEmulator(
      EnvConfig.firestoreHost,  // localhost
      EnvConfig.firestorePort,  // 8080
    );
    await FirebaseAuth.instance.useAuthEmulator(
      EnvConfig.authHost,       // localhost
      EnvConfig.authPort,       // 9099
    );
  }

  runApp(const MyApp());
}
```

### Environment Configuration

**File:** `lib/env_config.dart`

```dart
class EnvConfig {
  static const bool useEmulator = bool.fromEnvironment(
    'USE_EMULATOR',
    defaultValue: false,
  );

  static const String firestoreHost = String.fromEnvironment(
    'FIRESTORE_HOST',
    defaultValue: 'localhost',
  );

  static const int firestorePort = int.fromEnvironment(
    'FIRESTORE_PORT',
    defaultValue: 8080,
  );

  static const String authHost = String.fromEnvironment(
    'AUTH_HOST',
    defaultValue: 'localhost',
  );

  static const int authPort = int.fromEnvironment(
    'AUTH_PORT',
    defaultValue: 9099,
  );
}
```

**Usage in Docker:**
```bash
flutter build web --release \
  --dart-define=USE_EMULATOR=true \
  --dart-define=FIRESTORE_HOST=localhost \
  --dart-define=FIRESTORE_PORT=8080 \
  --dart-define=AUTH_HOST=localhost \
  --dart-define=AUTH_PORT=9099
```

### Firestore Collections

**Collection: `gyms`**
```
gyms/{gymId}
├── name: string
├── activeSeasonId: string? (optional)
└── baseMetaData: object
    ├── createdByUid: string
    ├── lastUpdateByUid: string
    ├── createdAt: timestamp
    └── lastUpdateAt: timestamp
```

**Collection: `seasons`**
```
seasons/{seasonId}
├── gymId: string
├── name: string
├── startDate: timestamp
├── endDate: timestamp
└── baseMetaData: object
```

**Collection: `boulders`**
```
boulders/{boulderId}
├── gymId: string
├── name: string
├── week: number (1-12)
├── seasonId: string
└── baseMetaData: object
```

**Collection: `scores`**
```
scores/{scoreId}
├── uid: string
├── boulderId: string
├── gymId: string
├── seasonId: string
├── week: number
├── attempts: number
├── completed: boolean
├── score: number
├── displayName: string? (optional)
└── baseMetaData: object
```

### Firestore Security Rules

**File:** `firestore.rules`

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow authenticated users to read/write all collections
    // TODO: Implement granular permissions
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

**Note:** Currently permissive - requires granular rules for production.

### Firestore Indexes

**File:** `firestore.indexes.json`

Required composite indexes:
- `boulders`: gymId, seasonId, week
- `scores`: uid, seasonId (for leaderboard queries)

### Firebase Emulators

**Configuration File:** `firebase.json`

```json
{
  "emulators": {
    "auth": {
      "port": 9099,
      "host": "0.0.0.0"
    },
    "firestore": {
      "port": 8080,
      "host": "0.0.0.0"
    },
    "ui": {
      "enabled": true,
      "port": 4000,
      "host": "0.0.0.0"
    },
    "singleProjectMode": true
  }
}
```

**Default Test Data:**
- Located in: `default-test-data/`
- Imported on emulator startup
- Contains sample gyms, seasons, boulders, users, scores

**Emulator UI Access:**
- Local: `http://localhost:4000`
- Docker: `http://localhost:4000` (via proxy)

---

## 11. Service Flow Diagrams

### Authentication Flow

```
┌─────────────────────────────────────────────────────┐
│                  User Not Authenticated              │
└───────────────────┬─────────────────────────────────┘
                    │
                    ▼
         ┌──────────────────────┐
         │   LoginScreen         │
         │  (LoginCardForm)      │
         └──────────┬────────────┘
                    │ Submit email/password
                    ▼
         ┌──────────────────────┐
         │   AuthService.login() │
         └──────────┬────────────┘
                    │
         ┌──────────▼───────────┐
         │  Firebase Auth API    │
         └──────────┬────────────┘
                    │
         ┌──────────▼───────────┐
         │  Success? Yes → Home  │
         │           No → Error  │
         └───────────────────────┘
```

### Data Flow: Creating a Score

```
┌─────────────────────────────────────────────────────┐
│  ScoresSection (Loads Gyms, Seasons, Weeks)         │
└───────────────────┬─────────────────────────────────┘
                    │
                    ▼
         ┌──────────────────────┐
         │   ScoresForm          │
         │  - Select Season      │
         │  - Select Week        │
         │  - Select Boulder     │◄─── Filtered by Season+Week
         │  - Enter Attempts     │
         │  - Check Completed    │
         └──────────┬────────────┘
                    │ Submit
                    ▼
         ┌──────────────────────────────┐
         │  ScoreCalculator.calculate()  │
         │  completed ? 100 + bonus      │
         │           : 0                 │
         └──────────┬───────────────────┘
                    │
                    ▼
         ┌──────────────────────────────┐
         │  ScoringService.addScore()    │
         │  - Check duplicate            │
         │  - Create Firestore doc       │
         └──────────┬───────────────────┘
                    │
                    ▼
         ┌──────────────────────────────┐
         │  Firestore Collection: scores │
         └──────────┬───────────────────┘
                    │ Real-time update
                    ▼
         ┌──────────────────────────────┐
         │  ScoresTable StreamBuilder    │
         │  (Displays updated scores)    │
         └───────────────────────────────┘
```

### Data Flow: Leaderboard Generation

```
┌─────────────────────────────────────────────────────┐
│  LeaderboardSection                                  │
│  - User selects Gym                                  │
│  - Auto-selects activeSeasonId or manual select      │
└───────────────────┬─────────────────────────────────┘
                    │
                    ▼
         ┌──────────────────────────────┐
         │  ScoringService.getScores()   │
         │  filters: { seasonId }        │
         └──────────┬───────────────────┘
                    │ Stream<List<ScoredBoulder>>
                    ▼
         ┌──────────────────────────────┐
         │  LeaderboardTable             │
         │  - Group by uid               │
         │  - Sum totalScore per user    │
         │  - Create LeaderboardEntry[]  │
         │  - Sort by totalScore DESC    │
         └──────────┬───────────────────┘
                    │
                    ▼
         ┌──────────────────────────────┐
         │  Display Ranked Table         │
         │  Rank | Username | Score      │
         │    1  | Alice    | 523.4      │
         │    2  | Bob      | 498.7      │
         └───────────────────────────────┘
```

### Service Layer Architecture

```
┌───────────────────────────────────────────────────────────┐
│                      UI Layer (Widgets)                    │
│  Sections → Forms/Tables → StreamBuilder/FutureBuilder    │
└───────────────────────┬───────────────────────────────────┘
                        │
                        ▼
┌───────────────────────────────────────────────────────────┐
│                   Service Layer                            │
│                                                            │
│  ┌─────────────┐  ┌──────────────┐  ┌─────────────┐      │
│  │ AuthService │  │ GymService   │  │ BoulderServ │      │
│  └──────┬──────┘  └──────┬───────┘  └──────┬──────┘      │
│         │                │                  │             │
│  ┌──────┴──────┐  ┌──────┴───────┐  ┌──────┴──────┐      │
│  │SeasonService│  │ScoringService│  │             │      │
│  └──────┬──────┘  └──────┬───────┘  └─────────────┘      │
│         │                │                                │
│         ▼                ▼                                │
│  All services return:                                     │
│  - Future<BaseReturnObject> (CRUD operations)             │
│  - Stream<List<T>> (Query operations)                     │
└───────────────────────┬───────────────────────────────────┘
                        │
                        ▼
┌───────────────────────────────────────────────────────────┐
│                   Firebase Layer                           │
│                                                            │
│  ┌──────────────────┐          ┌──────────────────┐       │
│  │ Firebase Auth     │          │ Cloud Firestore  │       │
│  │ - login()         │          │ - collection()   │       │
│  │ - createUser()    │          │ - doc()          │       │
│  │ - updateProfile() │          │ - set()/update() │       │
│  └──────────────────┘          │ - snapshots()    │       │
│                                 └──────────────────┘       │
└───────────────────────┬───────────────────────────────────┘
                        │
                        ▼
┌───────────────────────────────────────────────────────────┐
│           Firebase Emulators (Development)                 │
│           Firebase Production (Deployment)                 │
└───────────────────────────────────────────────────────────┘
```

---

## 12. Testing Configuration

### Integration Tests

**Location:** `integration_test/`

**Structure:**
```
integration_test/
├── helpers/         # Test helper utilities
└── services/        # Service integration tests
```

**Note:** Integration test files are being developed. Current focus is on service layer testing with Firebase emulators.

### Running Tests

```bash
# Unit tests
flutter test

# Integration tests (requires emulators running)
firebase emulators:start --import ./default-test-data
flutter test integration_test/
```

### Test Data

**Location:** `default-test-data/`

**Contents:**
- Pre-populated Firebase Auth users
- Sample gyms, seasons, boulders
- Sample scored boulders for multiple users

**Usage:**
```bash
# Start emulators with test data
firebase emulators:start --import ./default-test-data

# Export updated test data
firebase emulators:export ./default-test-data
```

---

## 13. Build & Deployment

### Development Builds

**Web:**
```bash
# Development mode (with emulators)
flutter run -d chrome

# Or via Docker
docker-compose -f .docker/docker-compose.yml up web
```

**iOS:**
```bash
# Open Xcode
open ios/Runner.xcworkspace

# Or via Flutter
flutter run -d ios

# Build for device
flutter build ios --release
```

**Android:**
```bash
# Run on emulator/device
flutter run -d android

# Build APK
flutter build apk --release

# Build App Bundle (for Play Store)
flutter build appbundle --release
```

### Production Builds

**Web (Static Build):**
```bash
# Build without emulators
flutter build web --release \
  --dart-define=USE_EMULATOR=false

# Output: build/web/
```

**Web (Docker Production):**
```bash
# Build production image
docker build \
  --build-arg USE_EMULATOR=false \
  -f .docker/Dockerfile \
  -t boulder-league-app:production .

# Run production container
docker run -p 8000:80 boulder-league-app:production
```

**iOS (Production):**
```bash
# Build for App Store
flutter build ipa --release

# Output: build/ios/ipa/
```

**Android (Production):**
```bash
# Build signed App Bundle
flutter build appbundle --release

# Output: build/app/outputs/bundle/release/
```

### Environment Variables for Build

**For Docker builds:**
```env
USE_EMULATOR=false
FIRESTORE_HOST=<production-firestore-host>
FIRESTORE_PORT=443
AUTH_HOST=<production-auth-host>
AUTH_PORT=443
```

**For Flutter builds:**
```bash
flutter build web --release \
  --dart-define=USE_EMULATOR=false \
  --dart-define=FIRESTORE_HOST=firestore.googleapis.com \
  --dart-define=FIRESTORE_PORT=443
```

### Deployment Platforms

**Web:**
- Firebase Hosting
- AWS S3 + CloudFront
- Docker on cloud platforms (GCP, AWS, Azure)

**iOS:**
- Apple App Store (via TestFlight for beta)

**Android:**
- Google Play Store
- Direct APK distribution

---

## Summary

This context document provides complete coverage of the Boulder League App codebase, including:

- **Architecture**: Flutter frontend + Firebase backend
- **Data Models**: 6 main entities (Gym, Season, Boulder, ScoredBoulder, LeaderboardEntry, BaseMetaData)
- **Services**: 5 service classes (Auth, Gym, Season, Boulder, Scoring)
- **UI Components**: 30+ components following Section → Filters/Form/Table pattern
- **Screens**: 5 screens with bottom navigation
- **Docker**: 3-container setup (web, firebase, proxy)
- **Firebase**: Firestore collections, Auth, Emulators
- **Development**: Local setup, emulator usage, Docker workflows
- **Deployment**: Web, iOS, Android build processes

**Key Design Patterns:**
1. **Service Layer Pattern**: Consistent CRUD + query operations
2. **Real-time Data**: Firestore snapshots via StreamBuilder
3. **Filter-based Queries**: Stateful sections manage filter state
4. **Form Edit/Create Mode**: Single form component for both operations
5. **Score Calculation**: Pure function for deterministic scoring
6. **Toast Notifications**: Consistent success/error feedback

**Next Steps for AI Agents:**
- Use this context to understand codebase structure
- Follow established patterns when adding new features
- Maintain consistency in service methods and component architecture
- Test with Firebase emulators before production deployment
