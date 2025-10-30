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

### Prerequisites

- Ruby 2.6+ (check with `ruby --version`)
- Bundler (`gem install bundler`)
- Firebase CLI (`firebase --version`)
- Android keystore for signing

### One-Time Setup

**1. Install Fastlane Dependencies**

```bash
cd fastlane
bundle install
cd ..
```

**2. Create Android Keystore and Configure**

Use the interactive setup script:

```bash
./setup-keystore.sh
```

This script will:
- Guide you through creating a new keystore (or use an existing one)
- Automatically generate the `android/key.properties` file
- Set proper file permissions for security

Alternatively, you can do it manually:

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

**3. Get Firebase Token**

```bash
firebase login:ci
```

Save the token to `fastlane/DO_NOT_SHARE/firebase_token.txt`

### Version Management

The project uses Flutter's versioning in `pubspec.yaml` with format `versionName+versionCode` (e.g., `1.0.0+1`).

- **versionName** (1.0.0): Semantic version shown to users (major.minor.patch)
- **versionCode** (1): Integer build number for Android, auto-incremented

**Check Current Version:**
```bash
grep "^version:" pubspec.yaml
```

**Bump Version (Smart Bumping):**
```bash
bundle exec fastlane android bump
```

Version bumping rules based on git branch:
- **Release branches** (contains "release", e.g., `releases/1.0.0`): Bumps major version (`1.0.0+1` → `2.0.0+2`)
- **UAT branches** (contains "uat", e.g., `UAT/1.0.0`): Bumps minor version (`1.0.0+1` → `1.1.0+2`)
- **Other branches** (main, feature branches, etc.): Bumps patch version (`1.0.0+1` → `1.0.1+2`)

**Note:** versionCode is **always** incremented on every bump.

After bumping, commit the version change:
```bash
git add pubspec.yaml
git commit -m "Bump version to X.X.X+Y"
```

### Deploy Commands

All build and deploy commands **automatically bump the version** based on your current git branch.

**Build APK Only:**
```bash
bundle exec fastlane android build
```

This will:
1. Auto-bump version based on branch
2. Build the release APK

**Build and Deploy to Firebase:**
```bash
bundle exec fastlane android build_and_deploy
```

This will:
1. Auto-bump version based on branch
2. Build the release APK
3. Deploy to Firebase App Distribution

**Manual Version Bump (Optional):**
```bash
bundle exec fastlane android bump
```

Use this if you want to bump the version without building.

**With Custom Release Notes:**
```bash
bundle exec fastlane android build_and_deploy release_notes:"Version 1.0.0 - Bug fixes"
```

**Deploy to Specific Tester Groups:**
```bash
bundle exec fastlane android build_and_deploy groups:"internal,beta-testers"
```

**Note:** Firebase App Distribution tracks both release and build numbers:
- **Release Number**: Matches the versionName (e.g., "1.0.1")
- **Build Number**: Matches the versionCode (e.g., "2"), auto-increments each deployment

Example: Deploying version `1.0.1+2` will show as **Release 1.0.1, Build 2** in Firebase.

**Typical Workflow:**
```bash
# Option 1: Build and deploy in one command (RECOMMENDED)
bundle exec fastlane android build_and_deploy

# Option 2: Build first, then decide
bundle exec fastlane android build
# ... test the APK locally ...
# ... then deploy separately if needed ...

# Note: Version is auto-bumped, don't forget to commit
git add pubspec.yaml
git commit -m "Bump version to 1.0.1+2"
git push
```

### Testing Your Build

Before deploying, test locally:

```bash
flutter build apk --release
```

APK will be at: `build/app/outputs/flutter-apk/app-release.apk`

### Troubleshooting

**"Firebase token not found"**
- Create `fastlane/DO_NOT_SHARE/firebase_token.txt` with your token

**"key.properties not found"**
- Create `android/key.properties` as shown above

**Build fails**
- Run `flutter build apk --release` to test manually
- Check that keystore path is correct

**Ruby/Bundler errors**
- Run `bundle install` in the `fastlane` directory
- If using Ruby 3.4+, dependencies are already configured

For detailed documentation, see [fastlane/README.md](fastlane/README.md)

---

## Additional Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase Emulator Suite](https://firebase.google.com/docs/emulator-suite)
- [Flutter Firebase Setup](https://firebase.google.com/docs/flutter/setup)
- [Docker Documentation](https://docs.docker.com/)
- [Fastlane Documentation](https://docs.fastlane.tools/)
