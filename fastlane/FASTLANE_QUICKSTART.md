# Fastlane Quick Start - Android Firebase App Distribution

Simple guide to get Fastlane working for Android deployment.

---

## Prerequisites Check

```bash
ruby --version       # Should be 2.6+
firebase --version   # Firebase CLI installed
flutter --version    # Flutter SDK installed
```

---

## Setup (3 Steps)

### Step 1: Install Fastlane

```bash
cd fastlane
bundle install
cd ..
```

### Step 2: Setup Keystore (Easy Way)

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

### Step 3: Get Firebase Token

```bash
firebase login:ci
```

Save the token to `fastlane/DO_NOT_SHARE/firebase_token.txt`

---

## Usage

### Build Only
```bash
bundle exec fastlane android build
```

### Deploy to Firebase
```bash
bundle exec fastlane android deploy
```

### With Options
```bash
# Custom release notes
bundle exec fastlane android deploy release_notes:"Version 1.0.0"

# Specific tester groups
bundle exec fastlane android deploy groups:"internal,beta"

# Both
bundle exec fastlane android deploy \
  release_notes:"Version 1.0.0" \
  groups:"testers"
```

---

## Test Your Setup

```bash
# Test build
flutter build apk --release

# Output location
ls -lh build/app/outputs/flutter-apk/app-release.apk
```

---

## Troubleshooting

| Error | Solution |
|-------|----------|
| Firebase token not found | Create `fastlane/DO_NOT_SHARE/firebase_token.txt` |
| key.properties not found | Create `android/key.properties` |
| Build fails | Run `flutter build apk --release` to test |
| Ruby errors | Run `bundle install` in fastlane directory |

---

## File Locations

```
project/
├── fastlane/
│   ├── Fastfile                    # Lanes configuration
│   ├── Gemfile                     # Ruby dependencies
│   └── DO_NOT_SHARE/
│       └── firebase_token.txt      # Your Firebase token
│
└── android/
    └── key.properties              # Keystore config
```

---

## Security Checklist

- [ ] `key.properties` created and NOT in git
- [ ] Keystore backed up securely
- [ ] Firebase token saved in `DO_NOT_SHARE/`
- [ ] Passwords stored in password manager
- [ ] Verified: `git status` doesn't show secrets

---

**Ready to deploy!** 🚀

See [README.md](README.md#deployment---android-to-firebase-app-distribution) for full documentation.
