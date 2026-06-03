# ============================================================================
# Bimo-Nexus base image
# Multi-stage base der pre-installerer Node.js 22 + nginx + wget, så alle
# Bimo-Nexus services kan arve fra det og spare ~30s build-tid hver.
#
# Tagging:
#   docker build -t bimo-nexus-base:22-alpine .
# ============================================================================

# ---------- Build-stage base: Node + git + wget (til CI helpers) ----------
FROM node:22-alpine AS bimo-nexus-builder
RUN apk add --no-cache git wget curl bash
WORKDIR /app

# Pre-create de mapper alle services bruger så COPY-trin er hurtigere
RUN mkdir -p /app/src /app/public

# ---------- Runtime-stage base: nginx + wget (til healthcheck) ----------
FROM nginx:alpine AS bimo-nexus-runtime
RUN apk add --no-cache wget curl
# Standard security-headers + brotli-friendly config kan tilføjes her i fremtiden
# Hver service overrider default.conf via egen nginx.conf
HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3 \
  CMD wget -qO- http://localhost/health || exit 1
