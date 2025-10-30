# DO_NOT_SHARE Folder

⚠️ **This folder contains sensitive credentials - DO NOT commit to git**

## Required Files

### 1. firebase_token.txt
Get your Firebase token:
```bash
firebase login:ci
```
Save the token to this file (one line, no extra spaces).

### 2. firebase_android_app_id.txt
Your Android App ID from Firebase Console.

Default (already configured in Fastfile):
```
1:822562274761:android:a71a7fd2d78c1eb20bfc18
```

You only need this file if your App ID is different.

## Security

- ✅ This folder is gitignored
- ❌ Never commit these files
- ❌ Never share tokens publicly
- ✅ Store backups in password manager
