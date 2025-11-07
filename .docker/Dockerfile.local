# Stage 1: Build the Flutter web application
FROM ghcr.io/cirruslabs/flutter:stable AS build

# Build argument to specify which .env file to use
# Example: --build-arg ENV_FILE=.env.local
ARG ENV_FILE=.env

# Set working directory
WORKDIR /app

# Copy pubspec files and get dependencies
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Copy the rest of the application
COPY . .

# Copy the specified .env file
# This will fail if the specified ENV_FILE doesn't exist, which is what we want
COPY ${ENV_FILE} ./.env.build

# Verify the .env file exists and show its contents (for debugging)
RUN echo "Using environment file: ${ENV_FILE}" && \
    echo "Contents:" && \
    cat ./.env.build

# Read .env file and build with dart-define flags
# This uses a shell script to parse the .env file and pass values to flutter build
RUN set -a && \
    . ./.env.build && \
    set +a && \
    echo "Building with:" && \
    echo "  ENV=${ENV}" && \
    echo "  FIRESTORE_HOST=${FIRESTORE_HOST}" && \
    echo "  FIRESTORE_PORT=${FIRESTORE_PORT}" && \
    echo "  AUTH_HOST=${AUTH_HOST}" && \
    echo "  AUTH_PORT=${AUTH_PORT}" && \
    echo "  APPCHECK_RECAPTCHA_SITE_KEY=${APPCHECK_RECAPTCHA_SITE_KEY}" && \
    flutter build web --release \
      --dart-define=ENV=${ENV} \
      --dart-define=FIRESTORE_HOST=${FIRESTORE_HOST} \
      --dart-define=FIRESTORE_PORT=${FIRESTORE_PORT} \
      --dart-define=AUTH_HOST=${AUTH_HOST} \
      --dart-define=AUTH_PORT=${AUTH_PORT} \
      --dart-define=APPCHECK_RECAPTCHA_SITE_KEY=${APPCHECK_RECAPTCHA_SITE_KEY}

# Stage 2: Serve with nginx
FROM nginx:alpine

# Copy the built web app from the build stage
COPY --from=build /app/build/web /usr/share/nginx/html

# Copy custom nginx configuration
COPY .docker/nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
