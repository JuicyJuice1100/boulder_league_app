# Boulder League App

A Flutter application for managing boulder climbing leagues.

## Prerequisites

Before setting up the project, ensure you have the following installed:

- **Node.js**: v25.0.0 (or compatible version)
- **Java**: OpenJDK 25 (or compatible version)
- **Flutter SDK**: Latest stable version
- **Firebase CLI**: For running local emulators

### Docker Alternative

Alternatively, if you have Docker and Docker Compose installed, you can skip the manual setup and use the containerized environment (see [Docker Setup](#docker-setup) below).

## Local Development Setup

### 1. Install Flutter

If you don't have Flutter installed, follow these steps:

1. Download Flutter SDK from [flutter.dev](https://docs.flutter.dev/get-started/install)
2. Extract the downloaded archive to a desired location
3. Add Flutter to your PATH:
   ```bash
   export PATH="$PATH:[PATH_TO_FLUTTER_DIRECTORY]/flutter/bin"
   ```
4. Verify installation:
   ```bash
   flutter doctor
   ```
5. Follow any additional setup instructions from `flutter doctor` output


### 3. Install Firebase CLI

Install the Firebase CLI globally using npm:

```bash
curl -sL https://firebase.tools | bash
```

Verify installation:
```bash
firebase --version
```

### 4. Setup Firebase Emulator

The project uses Firebase emulators for local development with pre-configured test data.

#### Start the Firebase Emulator with Test Data

Run the following command from the project root:

```bash
firebase emulators:start --import ./default-test-data
```

This will:
- Start the Firebase Authentication emulator on port 9099
- Start the Firestore emulator on port 8080
- Import default test data from the `./default-test-data` directory
- Enable the Firebase Emulator UI (accessible via browser)

The emulator UI will be available at the URL shown in the terminal output (typically `http://localhost:4000`).

### 5. Run the Application

With the Firebase emulators running, start the Flutter app:

```bash
# Run on connected device or emulator
flutter run

# Or specify a device
flutter run -d <device-id>
```

To see available devices:
```bash
flutter devices
```

## Project Configuration

- **Firebase Project ID**: boulder-league-app
- **Firestore Database**: (default)
- **Emulator Ports**:
  - Auth: 9099
  - Firestore: 8080
  - UI: Enabled (default port)

## Docker Setup

The project includes Docker configuration for easy deployment and development.

### Prerequisites for Docker

- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)

### Initial Setup


The `.env.local` file is optional. If not present, Docker Compose will use the default values defined in the compose file.

### Running with Docker Compose

All Docker files are organized in the `.docker` folder. To run the entire application stack (Flutter web app + Firebase emulators + proxy):

```bash
# Using .env.local file (if it exists)
docker-compose -f .docker/docker-compose.yml up --build

# Or explicitly specify the env file
docker-compose -f .docker/docker-compose.yml --env-file .env.local up --build
```

For convenience, you can create an alias:
```bash
alias dc='docker-compose -f .docker/docker-compose.yml'
dc up --build
```

This will start three containers:
1. **web**: Flutter web application served on `http://localhost:8000`
2. **firebase**: Firebase emulators (Auth & Firestore) with test data
3. **firebase-proxy**: Nginx reverse proxy for the emulator UI

Access points:
- Flutter Web App: `http://localhost:8000` (configurable via `WEB_PORT` in `.env.local`)
- Firebase Emulator UI: `http://localhost:4000` (configurable via `FIREBASE_UI_PORT`)
- Firestore Emulator (direct): `localhost:8080` (configurable via `FIRESTORE_PORT`)
- Auth Emulator (direct): `localhost:9099` (configurable via `AUTH_PORT`)

The web app runs in your browser and connects directly to the Firebase emulators on the configured ports.

### Running Individual Services

You can run specific services using Docker Compose:

```bash
# Run only the web app (requires emulators to be running)
docker-compose -f .docker/docker-compose.yml up web

# Run only Firebase emulators
docker-compose -f .docker/docker-compose.yml up firebase

# Run Firebase emulators with proxy
docker-compose -f .docker/docker-compose.yml up firebase firebase-proxy
```

### Stopping Services

```bash
# Stop all services
docker-compose -f .docker/docker-compose.yml down

# Stop and remove volumes (clears emulator data)
docker-compose -f .docker/docker-compose.yml down -v
```

### Environment Configuration

The `.env.local` file contains all configurable environment variables:

```env
# Flutter Web App Configuration
USE_EMULATOR=true

# Firebase Emulator Hosts and Ports
FIRESTORE_HOST=localhost
FIRESTORE_PORT=8080
AUTH_HOST=localhost
AUTH_PORT=9099

# Container Port Mappings
WEB_PORT=8000
FIREBASE_UI_PORT=4000
```

**Note for Web Apps:** Flutter web apps run in the browser, not inside Docker containers. Therefore, emulator hosts should always be `localhost` since the browser connects from the host machine.

### Building for Production

To build the Docker image without emulator support (for production deployment):

```bash
docker build \
  --build-arg USE_EMULATOR=false \
  -f .docker/Dockerfile \
  -t boulder-league-app:latest .
```

Run the production image:
```bash
docker run -p 8000:80 boulder-league-app:latest
```

### Docker Architecture

The setup uses a three-container architecture with all Docker files organized in the `.docker` folder:

**File Structure:**
```
.docker/
├── docker-compose.yml      # Orchestrates all services
├── Dockerfile              # Web application build
├── Dockerfile.firebase     # Firebase emulators
├── Dockerfile.proxy        # Nginx proxy for emulator UI
├── nginx.conf              # Web app nginx config
└── nginx.proxy.conf        # Proxy nginx config

.env.local                  # Optional environment overrides (gitignored)
.env.example                # Example environment configuration
```

**1. Web Container (`boulder_league_web`)**
- Multi-stage build using Flutter official image for building
- Nginx alpine for serving the production build
- Port configurable via `WEB_PORT` (default: 8000)
- Dockerfile: `.docker/Dockerfile`

**2. Firebase Container (`boulder_league_firebase`)**
- Node.js alpine with Firebase CLI and OpenJDK 21 LTS
- Runs Auth and Firestore emulators
- Ports configurable via `FIRESTORE_PORT` and `AUTH_PORT`
- Loads test data on startup
- Dockerfile: `.docker/Dockerfile.firebase`

**3. Firebase Proxy Container (`boulder_league_firebase_proxy`)**
- Nginx alpine reverse proxy
- Provides access to Firebase Emulator UI
- Port configurable via `FIREBASE_UI_PORT` (default: 4000)
- Routes UI traffic to Firebase container
- Dockerfile: `.docker/Dockerfile.proxy`

**Architecture Benefits:**
- **Simple and clean**: Single compose file with sensible defaults
- **Environment-based configuration**: Optional `.env.local` for customization
- **Web app browser connectivity**: Flutter web connects to emulators via exposed localhost ports
- **Clean separation**: Each service has a single, well-defined responsibility
- **Network isolation**: Services communicate through a dedicated Docker bridge network
- **Flexible deployment**: Can run services individually or all together

## Deployment - Android to Firebase App Distribution

The project uses Fastlane to deploy Android builds to Firebase App Distribution for testing.

### Quick Start - Android Firebase App Distribution

Simple guide to get Fastlane working for Android deployment.

#### Prerequisites Check

```bash
ruby --version       # Should be 2.6+
firebase --version   # Firebase CLI installed
flutter --version    # Flutter SDK installed
```

#### Setup (3 Steps)

**Step 1: Install Fastlane**

```bash
cd fastlane
bundle install
cd ..
```

**Step 2: Setup Keystore (Easy Way)**

Run the interactive setup script:

```bash
./setup-keystore.sh
```

This will guide you through creating a keystore and automatically generate `android/key.properties`.

**Or do it manually:**

```bash
# Create keystore
keytool -genkey -v -keystore ~/keystores/boulder-league.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias boulder-league-key

# Create key.properties
cat > android/key.properties <<EOF
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=boulder-league-key
storeFile=/absolute/path/to/keystore.jks
EOF

chmod 600 android/key.properties
```

**Step 3: Setup Environment Configuration**

Copy the example environment files and update with your credentials:

```bash
cd fastlane
cp .env.fastlane.example DO_NOT_SHARE/.env.fastlane.dev
cp .env.fastlane.example DO_NOT_SHARE/.env.fastlane.uat
cp .env.fastlane.example DO_NOT_SHARE/.env.fastlane.prod
```

Edit each `.env` file in `fastlane/DO_NOT_SHARE/` to add:
1. **Firebase Token**: Run `firebase login:ci` to get your token
2. **Firebase Android App ID**: Find this in Firebase Console > Project Settings > General > Your apps

Example `.env.fastlane.dev` file:
```bash
DEBUG=true
ENV=dev
FIREBASE_TOKEN=your_actual_firebase_token_here
FIREBASE_ANDROID_APP_ID=1:822562274761:android:a71a7fd2d78c1eb20bfc18
```

### Version Management Guide

#### Version Format

Flutter uses the format: `versionName+versionCode` (e.g., `1.0.0+1`)

**versionName (Semantic Version)**
- Format: `MAJOR.MINOR.PATCH`
- **MAJOR**: Breaking changes or major releases
- **MINOR**: New features, UAT releases
- **PATCH**: Bug fixes, hotfixes, development builds

**versionCode (Build Number)**
- Integer that **always increments** with each bump
- Used by Android Play Store to identify builds
- Must always be greater than previous uploads

#### Version Files

Version information is stored and synchronized in two files:
1. **`pubspec.yaml`** - Primary source of truth for Flutter
2. **`android/local.properties`** - Used by Android Gradle build

Both files are automatically kept in sync by Fastlane.

**Check Current Version:**
```bash
grep "^version:" pubspec.yaml
# or
grep "flutter.version" android/local.properties
```

#### Automatic Version Bumping

**All build and deploy commands automatically bump the version!**

The version is automatically bumped based on your current git branch whenever you run:
- `fastlane android build` - Builds APK with auto-bump
- `fastlane android build_and_deploy` - Builds and deploys with auto-bump
- `fastlane android bump` - Manual bump only (no build)

**Bump Rules:**

| Branch Pattern | Bump Type | Example |
|---------------|-----------|---------|
| Contains "release" | Major + versionCode | `1.0.0+1` → `2.0.0+2` |
| Contains "uat" | Minor + versionCode | `1.0.0+1` → `1.1.0+2` |
| Any other branch | Patch + versionCode | `1.0.0+1` → `1.0.1+2` |

**Note:** versionCode is **always** incremented regardless of branch type.

**Branch Examples:**
- **Release Branches** (Major bump): `releases/1.0.0`, `release/v1.0.0`
- **UAT Branches** (Minor bump): `UAT/1.0.0`, `uat/feature-testing`
- **Other Branches** (Patch bump): `main`, `feature/new-ui`, `bugfix/login-issue`

**Important:** Before using Fastlane for the first time, ensure `android/local.properties` exists by running:
```bash
flutter build apk
# or
flutter run
```

### Deploy Commands

**Build APK Only (auto-bumps version):**
```bash
bundle exec fastlane android build env:dev
```

**Build and Deploy (auto-bumps version):**
```bash
# Development (default)
bundle exec fastlane android build_and_deploy env:dev

# UAT
bundle exec fastlane android build_and_deploy env:uat

# Production
bundle exec fastlane android build_and_deploy env:prod
```

This will:
1. Load environment configuration from `.env.fastlane.{env}`
2. Auto-bump version based on branch
3. Build the release APK
4. Deploy to Firebase App Distribution with environment-specific settings

**Manual Version Bump (Optional):**
```bash
bundle exec fastlane android bump
```

Use this if you want to bump the version without building.

**With Custom Release Notes:**
```bash
bundle exec fastlane android build_and_deploy env:prod \
  release_notes:"Version 1.0.0 - Initial production release"
```

**Deploy to Specific Tester Groups:**
```bash
bundle exec fastlane android build_and_deploy env:uat \
  groups:"internal,beta-testers"
```

**Note:** Firebase App Distribution tracks both release and build numbers:
- **Release Number**: Matches the versionName (e.g., "1.0.1")
- **Build Number**: Matches the versionCode (e.g., "2"), auto-increments each deployment

Example: Deploying version `1.0.1+2` will show as **Release 1.0.1, Build 2** in Firebase.

### Usage Examples

#### Typical Development Workflow

```bash
# On feature branch: feature/add-leaderboard
git checkout -b feature/add-leaderboard

# ... make changes ...

# Build and deploy (auto-bumps patch: 1.0.0+1 -> 1.0.1+2)
bundle exec fastlane android build_and_deploy env:dev

# Commit version change
git add pubspec.yaml android/local.properties
git commit -m "Bump version to 1.0.1+2"
git push
```

#### UAT Release Workflow

```bash
# Create UAT branch
git checkout -b UAT/1.0.0

# Build and deploy (auto-bumps minor: 1.0.0+1 -> 1.1.0+2)
bundle exec fastlane android build_and_deploy env:uat groups:"uat-testers"

# Commit version change
git add pubspec.yaml android/local.properties
git commit -m "Bump version to 1.1.0+2 for UAT testing"
git push
```

#### Production Release Workflow

```bash
# Create release branch
git checkout -b releases/1.1.0

# Build and deploy (auto-bumps major: 1.1.0+5 -> 2.0.0+6)
bundle exec fastlane android build_and_deploy env:prod \
  groups:"production" \
  release_notes:"Version 2.0.0 - Major Release"

# Commit version change
git add pubspec.yaml android/local.properties
git commit -m "Bump version to 2.0.0+6 for production release"
git push
```

### Firebase App Distribution Version Tracking

Firebase App Distribution tracks both the **release number** and **build number**:
- **Release Number**: Set to **versionName** (e.g., "1.0.1")
- **Build Number**: Set to **versionCode** (e.g., "2")

Each time you deploy:
- Release number updates based on branch (major/minor/patch bump)
- Build number increments automatically (1 → 2 → 3, etc.)
- Firebase shows releases grouped by version with individual builds
- Testers can see both the version and build number they're testing

**Why this matters:**
- You can deploy multiple test builds of the same release (e.g., Release 1.0.1 with Builds 2, 3, 4)
- Each release can have multiple iterations during testing
- Version changes are semantic (1.0.1 → 1.0.2), builds are sequential (2 → 3 → 4)

### Best Practices

#### 1. Use Auto-Bumping Commands

```bash
# Good workflow - version auto-bumps!
bundle exec fastlane android build_and_deploy env:dev
git add pubspec.yaml android/local.properties
git commit -m "Bump version"
```

#### 2. Use Branch Naming Conventions

Follow the branch naming patterns to get correct automatic bumping:
- **Features**: `feature/description`
- **Bugfixes**: `bugfix/description`
- **UAT**: `UAT/version` or `uat/description`
- **Releases**: `releases/version` or `release/description`

#### 3. Keep Version Files Committed

Always commit version changes to git:
```bash
git add pubspec.yaml android/local.properties
git commit -m "Bump version to X.X.X+Y"
```

#### 4. Never Decrease versionCode

The versionCode must always increase. Never manually set it to a lower number than previously deployed builds, as Android Play Store will reject the upload.

#### 5. Include Version in Release Notes

```bash
bundle exec fastlane android build_and_deploy env:prod \
  release_notes:"Version 1.0.0 - Initial production release with user authentication and leaderboard"
```

### Testing Your Build

Before deploying, test locally:

```bash
flutter build apk --release
```

APK will be at: `build/app/outputs/flutter-apk/app-release.apk`

### Troubleshooting

| Error | Solution |
|-------|----------|
| Firebase token not found | Add `FIREBASE_TOKEN` to your `.env` file |
| Firebase App ID not found | Add `FIREBASE_ANDROID_APP_ID` to your `.env` file |
| key.properties not found | Run `./setup-keystore.sh` or create manually |
| Build fails | Run `flutter build apk --release` to test |
| Ruby errors | Run `bundle install` in fastlane directory |
| local.properties not found | Run `flutter build apk` to generate it |
| Version not changing | Check you're on the right branch |
| Wrong bump type | Ensure branch name contains correct keyword (release/uat) |

### Security Checklist

- [ ] `key.properties` created and NOT in git
- [ ] Keystore backed up securely
- [ ] `.env` files in `DO_NOT_SHARE/` folder
- [ ] Firebase token and App ID added to `.env` files
- [ ] Passwords stored in password manager
- [ ] Verified: `git status` doesn't show secrets

### File Locations

```
project/
├── pubspec.yaml                       # Contains version: versionName+versionCode
├── setup-keystore.sh                  # Interactive keystore setup script
├── fastlane/
│   ├── Fastfile                       # Lanes configuration
│   ├── Gemfile                        # Ruby dependencies
│   ├── .env.fastlane.example          # Example environment configuration
│   └── DO_NOT_SHARE/
│       ├── .env.fastlane.dev          # Development environment config
│       ├── .env.fastlane.uat          # UAT environment config
│       └── .env.fastlane.prod         # Production environment config
│
└── android/
    ├── key.properties                 # Keystore config
    └── local.properties               # Auto-synced version info
```

For detailed Fastlane documentation, see [fastlane/README.md](fastlane/README.md)

---

## Additional Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase Emulator Suite](https://firebase.google.com/docs/emulator-suite)
- [Flutter Firebase Setup](https://firebase.google.com/docs/flutter/setup)
- [Docker Documentation](https://docs.docker.com/)
- [Fastlane Documentation](https://docs.fastlane.tools/)
