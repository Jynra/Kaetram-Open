# Client image for Kaetram (served on port 3174)
# Build stage
FROM node:20-alpine AS builder
RUN apk add --no-cache python3 make g++ git
WORKDIR /app

# Copy full repo for monorepo correctness
COPY . .

# Default client env (read by @kaetram/common/config at build time)
COPY docker/.env.client .env

# Yarn
RUN corepack enable && yarn install --immutable

# Build the client
RUN yarn workspace @kaetram/client build

# Runtime stage using nginx to serve static site
FROM nginx:alpine AS runtime

# Copy built client assets
COPY --from=builder /app/packages/client/dist /usr/share/nginx/html

# Nginx config to listen on 3174
COPY docker/nginx-client.conf /etc/nginx/conf.d/default.conf

EXPOSE 3174

CMD ["nginx", "-g", "daemon off;"]
