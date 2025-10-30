# Version Management Guide

This project uses Flutter's versioning with intelligent branch-based version bumping.

## Version Format

Flutter uses the format: `versionName+versionCode` (e.g., `1.0.0+1`)

### versionName (Semantic Version)

Format: `MAJOR.MINOR.PATCH`

- **MAJOR**: Breaking changes or major releases
- **MINOR**: New features, UAT releases
- **PATCH**: Bug fixes, hotfixes, development builds

### versionCode (Build Number)

- Integer that **always increments** with each bump
- Used by Android Play Store to identify builds
- Must always be greater than previous uploads

## Version File

Current version is stored in `pubspec.yaml` at the project root.

```bash
# Check current version
grep "^version:" pubspec.yaml
```

Example output: `version: 1.0.0+1`

## Automatic Version Bumping

**All build and deploy commands automatically bump the version!**

The version is automatically bumped based on your current git branch whenever you run:
- `fastlane android build` - Builds APK with auto-bump
- `fastlane android build_and_deploy` - Builds and deploys with auto-bump
- `fastlane android bump` - Manual bump only (no build)

### Bump Rules

| Branch Pattern | Bump Type | Example |
|---------------|-----------|---------|
| Contains "release" | Major + versionCode | `1.0.0+1` → `2.0.0+2` |
| Contains "uat" | Minor + versionCode | `1.0.0+1` → `1.1.0+2` |
| Any other branch | Patch + versionCode | `1.0.0+1` → `1.0.1+2` |

**Note:** versionCode is **always** incremented regardless of branch type.

### Branch Examples

**Release Branches** (Major bump):
- `releases/1.0.0` → bumps to `2.0.0+2`
- `release/v1.0.0` → bumps to `2.0.0+2`
- `hotfix/release-critical-bug` → bumps to major version

**UAT Branches** (Minor bump):
- `UAT/1.0.0` → bumps to `1.1.0+2`
- `uat/feature-testing` → bumps to `1.1.0+2`
- `UAT-testing` → bumps to minor version

**Other Branches** (Patch bump):
- `main` → bumps to `1.0.1+2`
- `feature/new-ui` → bumps to `1.0.1+2`
- `bugfix/login-issue` → bumps to `1.0.1+2`
- `develop` → bumps to patch version

## Usage Examples

### Typical Development Workflow

```bash
# On feature branch: feature/add-leaderboard
git checkout -b feature/add-leaderboard

# ... make changes ...

# Build and deploy (auto-bumps patch: 1.0.0+1 -> 1.0.1+2)
bundle exec fastlane android build_and_deploy

# Commit version change
git add pubspec.yaml
git commit -m "Bump version to 1.0.1+2"
git push
```

### UAT Release Workflow

```bash
# Create UAT branch
git checkout -b UAT/1.0.0

# Build and deploy (auto-bumps minor: 1.0.0+1 -> 1.1.0+2)
bundle exec fastlane android build_and_deploy groups:"uat-testers"

# Commit version change
git add pubspec.yaml
git commit -m "Bump version to 1.1.0+2 for UAT testing"
git push
```

### Production Release Workflow

```bash
# Create release branch
git checkout -b releases/1.1.0

# Build and deploy (auto-bumps major: 1.1.0+5 -> 2.0.0+6)
bundle exec fastlane android build_and_deploy \
  groups:"production" \
  release_notes:"Version 2.0.0 - Major Release"

# Commit version change
git add pubspec.yaml
git commit -m "Bump version to 2.0.0+6 for production release"
git push
```

## Manual Version Override

If you need to manually set a version:

```bash
# Edit pubspec.yaml and change the version line
# version: 2.5.3+10

# Commit the change
git add pubspec.yaml
git commit -m "Set version to 2.5.3+10"
```

## Version in Deployments

The version from `pubspec.yaml` is automatically:
- Included in release notes (unless custom notes are provided)
- Displayed during build and deployment
- Used by Android for app identification (versionCode) and display (versionName)
- Tracked by Firebase App Distribution using **versionCode as the build number**

### Firebase App Distribution Version and Build Tracking

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

Example deployment output:
```
📌 Current version: 1.0.0+1
   versionName: 1.0.0
   versionCode: 1
⬆️  Bumping version:
   1.0.0 -> 1.0.1 (versionName)
   1 -> 2 (versionCode)
✅ Version bumped to 1.0.1+2

🚀 Deploying to Firebase App Distribution...
   Version: 1.0.1+2
   Release Number: 1.0.1
   Build Number: 2
✅ Deployed to Firebase App Distribution!
   Release: 1.0.1
   Build: 2
```

In Firebase Console, this will appear as:
- **Release**: 1.0.1 (matches versionName)
- **Build**: 2 (matches versionCode)
- **Release Notes**: "Version 1.0.1 (Build 2) - New build from Fastlane"

## Best Practices

### 1. Use Auto-Bumping Commands

```bash
# Good workflow - version auto-bumps!
bundle exec fastlane android build_and_deploy
git add pubspec.yaml && git commit -m "Bump version"

# Also good - just building
bundle exec fastlane android build
git add pubspec.yaml && git commit -m "Bump version"
```

### 2. Use Branch Naming Conventions

Follow the branch naming patterns to get correct automatic bumping:
- **Features**: `feature/description`
- **Bugfixes**: `bugfix/description`
- **UAT**: `UAT/version` or `uat/description`
- **Releases**: `releases/version` or `release/description`

### 3. Keep pubspec.yaml Committed

Always commit `pubspec.yaml` changes to git:
```bash
git add pubspec.yaml
git commit -m "Bump version to X.X.X+Y"
```

### 4. Never Decrease versionCode

The versionCode must always increase. Never manually set it to a lower number than previously deployed builds, as Android Play Store will reject the upload.

### 5. Version in Release Notes

Include version in meaningful release notes:
```bash
bundle exec fastlane android build_and_deploy \
  release_notes:"Version 1.0.0 - Initial production release with user authentication and leaderboard"
```

## Troubleshooting

### Version Not Changing

**Problem**: Running `bump` but version stays the same

**Solution**: Check if you're on the right branch
```bash
git branch  # Check current branch
git checkout <correct-branch>
bundle exec fastlane android bump
```

### Wrong Bump Type

**Problem**: Got patch bump instead of minor/major

**Solution**: Check branch name contains the right keyword
```bash
# For UAT: branch must contain "uat" (case insensitive)
git checkout -b UAT/testing

# For Release: branch must contain "release" (case insensitive)
git checkout -b releases/1.0.0
```

### Version File Missing or Malformed

**Problem**: `pubspec.yaml` doesn't have version or format is wrong

**Solution**: Add or fix the version line in pubspec.yaml
```bash
# Edit pubspec.yaml and add/fix:
version: 1.0.0+1

git add pubspec.yaml
git commit -m "Fix version format"
```

## Integration with CI/CD

If you're using CI/CD pipelines, the version bump can be automated:

```yaml
# Example GitHub Actions workflow
- name: Bump Version
  run: |
    cd fastlane
    bundle exec fastlane android bump

- name: Commit Version
  run: |
    git config user.name "CI Bot"
    git config user.email "ci@example.com"
    git add pubspec.yaml
    git commit -m "Bump version [skip ci]"
    git push

- name: Deploy
  run: |
    cd fastlane
    bundle exec fastlane android deploy
```

## Version History

Track your version history with git tags:

```bash
# After bumping to a release version
VERSION=$(cat version.txt)
git tag -a "v$VERSION" -m "Release version $VERSION"
git push origin "v$VERSION"

# View version history
git tag -l "v*"
```

## Summary Commands

```bash
# Check current version
grep "^version:" pubspec.yaml

# Bump version (smart based on branch)
bundle exec fastlane android bump

# Commit version change
git add pubspec.yaml && git commit -m "Bump version"

# Build and deploy with auto-bump
bundle exec fastlane android build_and_deploy

# View all available lanes
bundle exec fastlane lanes
```

---

For deployment details, see [README.md](README.md#deployment---android-to-firebase-app-distribution)

For quick reference, see [fastlane/FASTLANE_QUICKSTART.md](fastlane/FASTLANE_QUICKSTART.md)
