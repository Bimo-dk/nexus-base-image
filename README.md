# nexus-base-image

Shared Docker base image for all Bimo-Nexus services. Pre-installs Node.js 22, nginx, wget, curl and git so each service does not need to apk-add them during build.

## Build & publish

```bash
docker build -t bimo-nexus-base:22-alpine .
docker tag bimo-nexus-base:22-alpine ghcr.io/bimo-dk/nexus-base:22-alpine
docker push ghcr.io/bimo-dk/nexus-base:22-alpine
```

## Usage in other services

```dockerfile
# Build stage (Node + dependencies)
FROM ghcr.io/bimo-dk/nexus-base:22-alpine AS bimo-nexus-builder AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Runtime stage (nginx + healthcheck)
FROM ghcr.io/bimo-dk/nexus-base:22-alpine AS bimo-nexus-runtime
COPY --from=builder /app/dist/<service-name>/browser /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
```

## Included

- **node:22-alpine** + `git`, `wget`, `curl`, `bash`
- **nginx:alpine** + `wget`, `curl` + standard HEALTHCHECK on `/health`

## Stages

| Stage | Contents | Usage |
|---|---|---|
| `bimo-nexus-builder` | Node 22 + git + wget | To npm install + build Angular/TypeScript |
| `bimo-nexus-runtime` | nginx + wget | To serve static files in prod |
