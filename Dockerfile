# Build stage
FROM dart:stable AS builder

WORKDIR /app

# Copy pubspec first for better caching
COPY pubspec.* ./
RUN dart pub get

# Copy source code
COPY . .

# Compile to native executable
RUN dart compile exe ./bin/main.dart -o ./build/bot

# Runtime stage - minimal image
FROM debian:bookworm-slim

# Install required dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy compiled binary
COPY --from=builder /app/build/bot /app/bot

# Railway PORT muhit o'zgaruvchisi
ENV PORT=8080

# Health check uchun
EXPOSE ${PORT}

# Run the bot
CMD ["./bot"]