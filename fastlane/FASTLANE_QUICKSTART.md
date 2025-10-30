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

### Version Management

**All build and deploy commands auto-bump the version!**

Version format: `versionName+versionCode` (e.g., `1.0.0+1`)
- **versionName**: User-facing version (major.minor.patch)
- **versionCode**: Build number (always incremented)

Smart bumping based on branch:
- `releases/X.X.X` → Major bump (`1.0.0+1` → `2.0.0+2`)
- `UAT/X.X.X` → Minor bump (`1.0.0+1` → `1.1.0+2`)
- Other branches → Patch bump (`1.0.0+1` → `1.0.1+2`)

**Check Current Version:**
```bash
grep "^version:" pubspec.yaml
```

**Manual Bump (Optional):**
```bash
bundle exec fastlane android bump
```

---

### Build & Deploy

**Build Only (auto-bumps):**
```bash
bundle exec fastlane android build
```

**Build and Deploy (auto-bumps):**
```bash
bundle exec fastlane android build_and_deploy
```

**Typical Workflow:**
```bash
# One command to build and deploy
bundle exec fastlane android build_and_deploy

# Don't forget to commit the version bump
git add pubspec.yaml && git commit -m "Bump version"
```

---

### Advanced Options

```bash
# Custom release notes
bundle exec fastlane android build_and_deploy release_notes:"Version 1.0.0"

# Specific tester groups
bundle exec fastlane android build_and_deploy groups:"internal,beta"

# Both
bundle exec fastlane android build_and_deploy \
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
├── pubspec.yaml                    # Contains version: versionName+versionCode
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
