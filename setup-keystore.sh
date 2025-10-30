#!/bin/bash

# Boulder League App - Keystore Setup Script
# This script helps create a keystore and generate the key.properties file

set -e

echo "=================================="
echo "Boulder League - Keystore Setup"
echo "=================================="
echo ""

# Check if key.properties already exists
if [ -f "android/key.properties" ]; then
    echo "⚠️  Warning: android/key.properties already exists!"
    read -p "Do you want to overwrite it? (y/N): " overwrite
    if [[ ! $overwrite =~ ^[Yy]$ ]]; then
        echo "Aborting."
        exit 0
    fi
    echo ""
fi

# Ask if user wants to create a new keystore
echo "Do you want to create a new keystore?"
echo "1) Yes, create a new keystore"
echo "2) No, I already have a keystore"
read -p "Choose option (1 or 2): " keystore_option
echo ""

if [ "$keystore_option" = "1" ]; then
    # Create new keystore
    echo "--- Creating New Keystore ---"
    echo ""

    # Get keystore location
    read -p "Enter keystore directory path (default: ~/keystores): " keystore_dir
    keystore_dir=${keystore_dir:-~/keystores}
    keystore_dir="${keystore_dir/#\~/$HOME}"  # Expand ~

    # Create directory if it doesn't exist
    mkdir -p "$keystore_dir"

    # Get keystore filename
    read -p "Enter keystore filename (default: boulder-league.jks): " keystore_filename
    keystore_filename=${keystore_filename:-boulder-league.jks}

    keystore_path="$keystore_dir/$keystore_filename"

    # Get key alias
    read -p "Enter key alias (default: boulder-league-key): " key_alias
    key_alias=${key_alias:-boulder-league-key}

    # Get passwords
    echo ""
    echo "Note: Passwords must be at least 6 characters"
    read -sp "Enter keystore password: " store_password
    echo ""
    read -sp "Confirm keystore password: " store_password_confirm
    echo ""

    if [ "$store_password" != "$store_password_confirm" ]; then
        echo "❌ Passwords don't match!"
        exit 1
    fi

    read -sp "Enter key password (press Enter to use same as keystore): " key_password
    echo ""

    if [ -z "$key_password" ]; then
        key_password="$store_password"
    fi

    # Check if keystore already exists
    if [ -f "$keystore_path" ]; then
        echo ""
        echo "⚠️  Warning: Keystore already exists at: $keystore_path"
        read -p "Do you want to overwrite it? (y/N): " overwrite_keystore
        if [[ ! $overwrite_keystore =~ ^[Yy]$ ]]; then
            echo "Using existing keystore."
        else
            rm "$keystore_path"
            echo ""
            echo "Creating keystore..."
            keytool -genkey -v -keystore "$keystore_path" \
                -keyalg RSA -keysize 2048 -validity 10000 \
                -alias "$key_alias" \
                -storepass "$store_password" \
                -keypass "$key_password"

            echo ""
            echo "✅ Keystore created successfully!"
        fi
    else
        echo ""
        echo "Creating keystore..."
        keytool -genkey -v -keystore "$keystore_path" \
            -keyalg RSA -keysize 2048 -validity 10000 \
            -alias "$key_alias" \
            -storepass "$store_password" \
            -keypass "$key_password"

        echo ""
        echo "✅ Keystore created successfully!"
    fi

elif [ "$keystore_option" = "2" ]; then
    # Use existing keystore
    echo "--- Using Existing Keystore ---"
    echo ""

    read -p "Enter full path to your keystore file: " keystore_path
    keystore_path="${keystore_path/#\~/$HOME}"  # Expand ~

    if [ ! -f "$keystore_path" ]; then
        echo "❌ Keystore file not found: $keystore_path"
        exit 1
    fi

    read -p "Enter key alias: " key_alias
    read -sp "Enter keystore password: " store_password
    echo ""
    read -sp "Enter key password: " key_password
    echo ""

else
    echo "❌ Invalid option"
    exit 1
fi

# Create key.properties file
echo ""
echo "Creating android/key.properties file..."

cat > android/key.properties <<EOF
storePassword=$store_password
keyPassword=$key_password
keyAlias=$key_alias
storeFile=$keystore_path
EOF

# Set restrictive permissions
chmod 600 android/key.properties

echo ""
echo "✅ key.properties created successfully!"
echo ""
echo "File location: android/key.properties"
echo "Permissions: 600 (read/write for owner only)"
echo ""
echo "--- Configuration Summary ---"
echo "Keystore: $keystore_path"
echo "Key Alias: $key_alias"
echo ""
echo "⚠️  IMPORTANT: Keep these credentials secure!"
echo "   - Never commit key.properties to git (already in .gitignore)"
echo "   - Store passwords in a secure password manager"
echo "   - Keep a backup of your keystore file"
echo ""
echo "You can now build a release APK with:"
echo "  flutter build apk --release"
echo ""
echo "Or deploy to Firebase App Distribution with:"
echo "  cd fastlane && bundle exec fastlane android deploy"
echo ""
