# nexus-base-image

Delt Docker base image til alle Bimo-Nexus services. Pre-installerer Node.js 22, nginx, wget, curl og git så hver service ikke skal apk-add'e dem under build.

## Build & publish

```bash
docker build -t bimo-nexus-base:22-alpine .
docker tag bimo-nexus-base:22-alpine ghcr.io/bimo-dk/nexus-base:22-alpine
docker push ghcr.io/bimo-dk/nexus-base:22-alpine
```

## Brug i andre services

```dockerfile
# Build-stage (Node + dependencies)
FROM ghcr.io/bimo-dk/nexus-base:22-alpine AS bimo-nexus-builder AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Runtime-stage (nginx + healthcheck)
FROM ghcr.io/bimo-dk/nexus-base:22-alpine AS bimo-nexus-runtime
COPY --from=builder /app/dist/<service-name>/browser /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
```

## Inkluderet

- **node:22-alpine** + `git`, `wget`, `curl`, `bash`
- **nginx:alpine** + `wget`, `curl` + standard HEALTHCHECK på `/health`

## Stages

| Stage | Indhold | Brug |
|---|---|---|
| `bimo-nexus-builder` | Node 22 + git + wget | Til at npm install + bygge Angular/TypeScript |
| `bimo-nexus-runtime` | nginx + wget | Til at serve statiske filer i prod |
