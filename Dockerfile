FROM ghcr.io/crisxzu/flutter-ci:latest AS builder

WORKDIR /app
COPY . .

ARG ENV_FILE
RUN echo "$ENV_FILE" | base64 -d > lib/env/env.g.dart

RUN flutter pub get && \
    flutter build web --release --dart-define=CI=true

FROM nginx:alpine

COPY --from=builder /app/build/web /usr/share/nginx/html

EXPOSE 80
