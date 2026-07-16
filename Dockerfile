FROM ghcr.io/crisxzu/flutter-ci:latest AS builder

WORKDIR /app
COPY . .

# 1. Deps, 2. build_runner pour générer les .g.dart (adapters Hive, non versionnés),
# 3. décoder env.g.dart APRÈS build_runner (sinon il serait écrasé), 4. build web.
ARG ENV_FILE
RUN flutter pub get && \
    dart run build_runner build --build-filter="lib/model/**" --delete-conflicting-outputs && \
    echo "$ENV_FILE" | base64 -d > lib/env/env.g.dart && \
    flutter build web --release

FROM nginx:alpine

COPY --from=builder /app/build/web /usr/share/nginx/html

EXPOSE 80
