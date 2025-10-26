# Stage 1: Build the Flutter web application
FROM ghcr.io/cirruslabs/flutter:stable AS build

# Build arguments for Firebase emulator configuration
ARG USE_EMULATOR=true
ARG FIRESTORE_HOST=firebase-proxy
ARG FIRESTORE_PORT=4000
ARG AUTH_HOST=firebase-proxy
ARG AUTH_PORT=4000

# Set working directory
WORKDIR /app

# Copy pubspec files and get dependencies
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Copy the rest of the application
COPY . .

# Build the Flutter web app with environment variables
RUN flutter build web --release \
    --dart-define=USE_EMULATOR=${USE_EMULATOR} \
    --dart-define=FIRESTORE_HOST=${FIRESTORE_HOST} \
    --dart-define=FIRESTORE_PORT=${FIRESTORE_PORT} \
    --dart-define=AUTH_HOST=${AUTH_HOST} \
    --dart-define=AUTH_PORT=${AUTH_PORT}

# Stage 2: Serve with nginx
FROM nginx:alpine

# Copy the built web app from the build stage
COPY --from=build /app/build/web /usr/share/nginx/html

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
