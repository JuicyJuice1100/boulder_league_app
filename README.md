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

The `.env.local` file is optional. If not present, Docker Compose will use the default values defined in `docker-compose.yml`.

### Running with Docker Compose

To run the entire application stack (Flutter web app + Firebase emulators + proxy):

```bash
# Using .env.local file (if it exists)
docker-compose up --build

# Or explicitly specify the env file
docker-compose --env-file .env.local up --build
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
docker-compose up web

# Run only Firebase emulators
docker-compose up firebase

# Run Firebase emulators with proxy
docker-compose up firebase firebase-proxy
```

### Stopping Services

```bash
# Stop all services
docker-compose down

# Stop and remove volumes (clears emulator data)
docker-compose down -v
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
  -t boulder-league-app:latest .
```

Run the production image:
```bash
docker run -p 8000:80 boulder-league-app:latest
```

### Docker Architecture

The setup uses a three-container architecture defined in a single `docker-compose.yml` file:

**File Structure:**
- `docker-compose.yml` - Defines all services with environment variable support
- `.env.local` - Optional environment variable overrides (gitignored)
- `.env.example` - Example environment configuration template

**1. Web Container (`boulder_league_web`)**
- Multi-stage build using Flutter official image for building
- Nginx alpine for serving the production build
- Port configurable via `WEB_PORT` (default: 8000)
- Dockerfile: `Dockerfile`

**2. Firebase Container (`boulder_league_firebase`)**
- Node.js alpine with Firebase CLI and OpenJDK 21 LTS
- Runs Auth and Firestore emulators
- Ports configurable via `FIRESTORE_PORT` and `AUTH_PORT`
- Loads test data on startup
- Dockerfile: `Dockerfile.firebase`

**3. Firebase Proxy Container (`boulder_league_firebase_proxy`)**
- Nginx alpine reverse proxy
- Provides access to Firebase Emulator UI
- Port configurable via `FIREBASE_UI_PORT` (default: 4000)
- Routes UI traffic to Firebase container
- Dockerfile: `Dockerfile.proxy`

**Architecture Benefits:**
- **Simple and clean**: Single compose file with sensible defaults
- **Environment-based configuration**: Optional `.env.local` for customization
- **Web app browser connectivity**: Flutter web connects to emulators via exposed localhost ports
- **Clean separation**: Each service has a single, well-defined responsibility
- **Network isolation**: Services communicate through a dedicated Docker bridge network
- **Flexible deployment**: Can run services individually or all together

## Additional Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase Emulator Suite](https://firebase.google.com/docs/emulator-suite)
- [Flutter Firebase Setup](https://firebase.google.com/docs/flutter/setup)
- [Docker Documentation](https://docs.docker.com/)
