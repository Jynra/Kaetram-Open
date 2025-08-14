# Server image for Kaetram (port 3173)
# Use a glibc-based image (uWebSockets prebuilt binaries require glibc)
FROM node:20-bookworm-slim

# Build deps for native modules
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 make g++ git ca-certificates curl \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy entire repository (simpler and more robust for this monorepo)
COPY . .

# Provide default server .env (used by packages/common/config.ts which reads ../../.env)
COPY docker/.env.server .env

# Enable Yarn 4 (Corepack) and install deps
RUN corepack enable && yarn install --immutable

# Build server workspace
RUN yarn workspace @kaetram/server build

ENV NODE_ENV=production

# Expose game server port
EXPOSE 3173

# Run from the server package directory
WORKDIR /app/packages/server

CMD ["node", "--enable-source-maps", "./dist/main.js"]
