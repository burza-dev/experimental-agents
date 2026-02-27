---
applyTo: "**/Dockerfile,**/docker-compose*.yml,**/*.dockerfile,**/devcontainer.json"
---

# Docker rules

Modern Docker practices for 2024-2026. Use BuildKit features, security hardening,
and efficient multi-stage builds.

## Dockerfile best practices

### Base image selection
- Use specific version tags, not `latest`
- Prefer slim/alpine variants for smaller images
- Use official images from Docker Hub
- Consider distroless or Chainguard images for minimal attack surface
- Pin to SHA digest for reproducibility: `FROM python:3.13@sha256:abc123...`

### Layer optimization
- Order commands from least to most frequently changing
- Combine related RUN commands with `&&`
- Clean up in the same layer (apt-get clean, rm cache)
- Use `.dockerignore` to exclude unnecessary files

### Multi-stage builds
- Use multi-stage builds to reduce image size
- Copy only artifacts needed for runtime
- Use builder pattern for compilation
- Name stages for clarity: `FROM ... AS builder`

## BuildKit features

Enable BuildKit with `DOCKER_BUILDKIT=1` or use Docker 23.0+ where it's default.

### Dockerfile syntax directive

```dockerfile
# syntax=docker/dockerfile:1.7
```

Place at the very first line to enable latest Dockerfile features.

### Build secrets

Never bake secrets into layers. Use secret mounts:

```dockerfile
# syntax=docker/dockerfile:1.7
FROM python:3.13

# Secret is available only during this RUN, not persisted in layer
RUN --mount=type=secret,id=pypi_token \
    pip install --index-url https://$(cat /run/secrets/pypi_token)@pypi.example.com/simple package
```

Build with:

```bash
docker build --secret id=pypi_token,src=.pypi_token .
```

### SSH mounts

Access private repos during build without exposing keys:

```dockerfile
# syntax=docker/dockerfile:1.7
FROM python:3.13-slim
RUN --mount=type=ssh \
    pip install git+ssh://git@github.com/org/private-repo.git
```

Build with:

```bash
eval $(ssh-agent)
ssh-add ~/.ssh/id_ed25519
docker build --ssh default .
```

### Cache mounts

Persist package manager caches across builds:

```dockerfile
# syntax=docker/dockerfile:1.7

# Python with pip cache
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install -r requirements.txt

# Python with uv cache
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen

# Node.js with npm cache
RUN --mount=type=cache,target=/root/.npm \
    npm ci

# apt cache
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && apt-get install -y package
```

### Multi-platform builds

Build for multiple architectures:

```bash
# Create builder (once)
docker buildx create --name multiarch --use

# Build for multiple platforms
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --tag myapp:latest \
  --push .
```

In Dockerfile, use multi-stage builds for multi-platform Python images:

```dockerfile
FROM --platform=$BUILDPLATFORM python:3.13-slim AS builder
ARG TARGETPLATFORM

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

COPY . .
RUN python manage.py collectstatic --noinput

FROM python:3.13-slim
COPY --from=builder /install /usr/local
COPY --from=builder /app /app
WORKDIR /app
USER nonroot
CMD ["gunicorn", "config.wsgi:application", "--bind", "0.0.0.0:8000"]
```

## Security best practices

### Non-root user

Always run as non-root in production:

```dockerfile
# Create user with specific UID/GID for consistency
RUN groupadd --gid 1000 appgroup && \
    useradd --uid 1000 --gid appgroup --shell /bin/false --create-home appuser

# Set ownership before switching user
COPY --chown=appuser:appgroup . /app

USER appuser
```

For distroless images:

```dockerfile
FROM gcr.io/distroless/python3-debian12
USER nonroot:nonroot
```

### Runtime security options

Run containers with minimal privileges:

```bash
docker run \
  --cap-drop=ALL \
  --cap-add=NET_BIND_SERVICE \
  --read-only \
  --security-opt=no-new-privileges:true \
  --tmpfs /tmp \
  myapp:latest
```

In docker-compose:

```yaml
services:
  app:
    image: myapp:latest
    cap_drop:
      - ALL
    cap_add:
      - NET_BIND_SERVICE
    read_only: true
    security_opt:
      - no-new-privileges:true
    tmpfs:
      - /tmp
```

### Image scanning

Integrate vulnerability scanning into workflow:

```bash
# Trivy (recommended)
trivy image myapp:latest
trivy image --severity HIGH,CRITICAL myapp:latest

# Grype
grype myapp:latest

# Docker Scout (built-in)
docker scout quickview myapp:latest
docker scout cves myapp:latest
```

### Dockerfile linting

Use Hadolint to catch issues:

```bash
# Local
hadolint Dockerfile

# In CI (GitHub Actions)
- uses: hadolint/hadolint-action@v3
  with:
    dockerfile: Dockerfile
```

Common Hadolint rules to follow:
- DL3008: Pin apt package versions
- DL3013: Pin pip package versions
- DL3018: Pin apk package versions
- DL4006: Set `SHELL` with pipefail for proper error handling

### Minimal base images

Prefer minimal images in order of security:

1. **Distroless** - minimal Google images, no shell
2. **Chainguard** - hardened images with SBOMs, updated daily
3. **Alpine** - minimal with musl libc, ~5MB
4. **Slim variants** - Debian-based but reduced, ~50-80MB

```dockerfile
# Distroless for Python
FROM gcr.io/distroless/python3-debian12

# Chainguard for Python
FROM cgr.dev/chainguard/python:latest
```

## Health checks

Define container health for orchestration:

```dockerfile
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8000/health || exit 1
```

### Health check options

| Option | Default | Description |
|--------|---------|-------------|
| `--interval` | 30s | Time between checks |
| `--timeout` | 30s | Max time for single check |
| `--start-period` | 0s | Grace period for startup |
| `--retries` | 3 | Failures before unhealthy |

### Health check patterns

```dockerfile
# HTTP endpoint
HEALTHCHECK CMD curl -f http://localhost:8000/health || exit 1

# Without curl (using wget in Alpine)
HEALTHCHECK CMD wget --spider --quiet http://localhost:8000/health || exit 1

# TCP port check
HEALTHCHECK CMD nc -z localhost 8000 || exit 1

# Redis
HEALTHCHECK CMD redis-cli ping | grep -q PONG || exit 1

# PostgreSQL
HEALTHCHECK CMD pg_isready -U postgres || exit 1

# Custom script
HEALTHCHECK CMD /app/healthcheck.sh || exit 1
```

### Disable inherited health check

```dockerfile
HEALTHCHECK NONE
```

## Python-specific patterns

### uv with Docker (recommended)

Efficient Python package management with proper caching:

```dockerfile
# syntax=docker/dockerfile:1.7
FROM python:3.13-slim AS builder

WORKDIR /app

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

# Copy dependency files
COPY pyproject.toml uv.lock ./

# Install dependencies with cache mount
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen --no-dev --no-install-project

# Copy source code
COPY src/ ./src/

# Install project
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen --no-dev

# Runtime stage
FROM python:3.13-slim

WORKDIR /app

# Create non-root user
RUN groupadd --gid 1000 app && \
    useradd --uid 1000 --gid app --create-home app

# Copy virtual environment
COPY --from=builder --chown=app:app /app/.venv /app/.venv

USER app

ENV PATH="/app/.venv/bin:$PATH"

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')" || exit 1

EXPOSE 8000
CMD ["python", "-m", "myapp"]
```

### pip with best practices

If using pip directly:

```dockerfile
FROM python:3.13-slim AS builder

WORKDIR /app

# Prevent bytecode and buffering
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Create virtual environment
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Install dependencies with no cache
COPY requirements.txt .
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install --no-cache-dir -r requirements.txt

# Runtime
FROM python:3.13-slim

COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

COPY . /app
WORKDIR /app

USER nobody
CMD ["python", "-m", "myapp"]
```

### Python .dockerignore

```text
# Git
.git/
.gitignore

# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
.venv/
venv/
ENV/
.eggs/
*.egg-info/
.mypy_cache/
.pytest_cache/
.coverage
htmlcov/
.tox/

# IDE
.vscode/
.idea/
*.swp
*.swo

# Docker
Dockerfile*
docker-compose*
.docker/

# Documentation
docs/
*.md
!README.md

# Tests (optional, include if needed)
tests/
*_test.py
test_*.py
conftest.py
```

## Docker Compose v2

Modern Compose syntax (no `version` field needed since Compose v2).

### Basic structure

```yaml
# No version field - uses latest Compose spec
services:
  api:
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - "8000:8000"
    environment:
      DATABASE_URL: postgresql://db:5432/app
    depends_on:
      db:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
    deploy:
      resources:
        limits:
          cpus: "0.5"
          memory: 512M
        reservations:
          memory: 256M

  db:
    image: postgres:16-alpine
    volumes:
      - postgres_data:/var/lib/postgresql/data
    environment:
      POSTGRES_PASSWORD_FILE: /run/secrets/db_password
    secrets:
      - db_password
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5

volumes:
  postgres_data:

secrets:
  db_password:
    file: ./secrets/db_password.txt
```

### Profiles for environments

```yaml
services:
  api:
    build: .
    profiles: ["dev", "prod"]

  db:
    image: postgres:16-alpine
    profiles: ["dev", "prod"]

  # Development only
  adminer:
    image: adminer
    ports:
      - "8080:8080"
    profiles: ["dev"]

  # Debug tools
  debug:
    image: busybox
    profiles: ["debug"]
```

Usage:

```bash
# Start dev environment
docker compose --profile dev up

# Start prod without debug tools
docker compose --profile prod up

# Add debug container
docker compose --profile dev --profile debug up
```

### Include for composition

Split compose files:

```yaml
# docker-compose.yml
include:
  - path: ./docker-compose.db.yml
  - path: ./docker-compose.monitoring.yml
    env_file: ./monitoring.env

services:
  api:
    build: .
    depends_on:
      - db
```

### depends_on with conditions

```yaml
services:
  api:
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_started
      migrations:
        condition: service_completed_successfully
```

Conditions:
- `service_started` - container started (default)
- `service_healthy` - health check passed
- `service_completed_successfully` - container exited with code 0

### Resource limits

```yaml
services:
  api:
    deploy:
      resources:
        limits:
          cpus: "1.0"
          memory: 1G
          pids: 100
        reservations:
          cpus: "0.25"
          memory: 256M
```

## Development containers

### devcontainer.json basics

```json
{
  "name": "Python Development",
  "image": "mcr.microsoft.com/devcontainers/python:3.13",
  "features": {
    "ghcr.io/devcontainers/features/docker-in-docker:2": {},
    "ghcr.io/devcontainers/features/git:1": {},
    "ghcr.io/devcontainers/features/github-cli:1": {}
  },
  "customizations": {
    "vscode": {
      "extensions": [
        "ms-python.python",
        "ms-python.vscode-pylance",
        "charliermarsh.ruff"
      ],
      "settings": {
        "python.defaultInterpreterPath": "/usr/local/bin/python"
      }
    }
  },
  "postCreateCommand": "uv sync",
  "remoteUser": "vscode"
}
```

### Using Dockerfile

```json
{
  "name": "Custom Dev Container",
  "build": {
    "dockerfile": "Dockerfile",
    "context": "..",
    "args": {
      "VARIANT": "3.13"
    }
  },
  "mounts": [
    "source=${localWorkspaceFolder}/.cache,target=/home/vscode/.cache,type=bind"
  ],
  "runArgs": ["--cap-add=SYS_PTRACE", "--security-opt", "seccomp=unconfined"],
  "postCreateCommand": "pip install -e '.[dev]'"
}
```

### Docker Compose integration

```json
{
  "name": "Full Stack",
  "dockerComposeFile": "../docker-compose.yml",
  "service": "api",
  "workspaceFolder": "/workspace",
  "shutdownAction": "stopCompose"
}
```

### Common features

```json
{
  "features": {
    // Docker-in-Docker
    "ghcr.io/devcontainers/features/docker-in-docker:2": {},
    
    // Languages
    "ghcr.io/devcontainers/features/python:1": { "version": "3.13" },
    "ghcr.io/devcontainers/features/node:1": { "version": "20" },
    
    // Tools
    "ghcr.io/devcontainers/features/kubectl-helm-minikube:1": {},
    "ghcr.io/devcontainers/features/terraform:1": {},
    "ghcr.io/devcontainers/features/aws-cli:1": {}
  }
}
```

## CI/CD patterns

### GitHub Actions with Docker

```yaml
name: Build and Push

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Login to Registry
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Build and push
        uses: docker/build-push-action@v6
        with:
          context: .
          push: ${{ github.event_name != 'pull_request' }}
          tags: |
            ghcr.io/${{ github.repository }}:${{ github.sha }}
            ghcr.io/${{ github.repository }}:latest
          cache-from: type=gha
          cache-to: type=gha,mode=max
          platforms: linux/amd64,linux/arm64
```

### Layer caching strategies

```yaml
# GitHub Actions cache
- uses: docker/build-push-action@v6
  with:
    cache-from: type=gha
    cache-to: type=gha,mode=max

# Registry cache (faster for large images)
- uses: docker/build-push-action@v6
  with:
    cache-from: type=registry,ref=ghcr.io/org/app:cache
    cache-to: type=registry,ref=ghcr.io/org/app:cache,mode=max

# Local cache (self-hosted runners)
- uses: docker/build-push-action@v6
  with:
    cache-from: type=local,src=/tmp/.buildx-cache
    cache-to: type=local,dest=/tmp/.buildx-cache-new,mode=max
```

### Image tagging strategies

```yaml
- name: Docker metadata
  id: meta
  uses: docker/metadata-action@v5
  with:
    images: ghcr.io/${{ github.repository }}
    tags: |
      # Branch name
      type=ref,event=branch
      # PR number
      type=ref,event=pr
      # Git tag (semver)
      type=semver,pattern={{version}}
      type=semver,pattern={{major}}.{{minor}}
      # SHA
      type=sha,prefix=
      # Latest for default branch
      type=raw,value=latest,enable={{is_default_branch}}

- uses: docker/build-push-action@v6
  with:
    tags: ${{ steps.meta.outputs.tags }}
    labels: ${{ steps.meta.outputs.labels }}
```

### Security scanning in CI

```yaml
- name: Build image
  uses: docker/build-push-action@v6
  with:
    load: true
    tags: myapp:${{ github.sha }}

- name: Scan with Trivy
  uses: aquasecurity/trivy-action@master
  with:
    image-ref: myapp:${{ github.sha }}
    format: "sarif"
    output: "trivy-results.sarif"
    severity: "CRITICAL,HIGH"

- name: Upload Trivy scan results
  uses: github/codeql-action/upload-sarif@v3
  with:
    sarif_file: "trivy-results.sarif"
```

## Forbidden practices

| Bad Practice | Why | Alternative |
|--------------|-----|-------------|
| `FROM ubuntu:latest` | Unpredictable, may break builds | `FROM ubuntu:24.04` |
| `ADD` for local files | Unnecessary features, less explicit | `COPY` for local files |
| `RUN apt-get install` (no clean) | Bloated layers | Clean in same layer |
| Secrets in `ENV` or `ARG` | Visible in image history | BuildKit secrets mount |
| Running as root | Security risk | Create and use non-root user |
| `COPY . .` without .dockerignore | Includes unnecessary files | Proper .dockerignore |
| Multiple `RUN apt-get update` | Stale package lists | Single update + install |
| Storing data in container | Data loss on restart | Use volumes |
| `--privileged` | Full host access | Specific `--cap-add` |
| `EXPOSE` everything | Unnecessary attack surface | Only needed ports |
| No health check | Orchestrator can't monitor | Define `HEALTHCHECK` |
| `pip install` without `--no-cache-dir` | Wasted space | Use `--no-cache-dir` or cache mount |
| Building as root in multi-stage | File permission issues | Match UIDs or use `--chown` |
| `docker-compose` v1 command | Deprecated | Use `docker compose` v2 |
| `version: "3.x"` in compose | Obsolete, limits features | Omit version field |

## Quick reference

### Essential commands

```bash
# Build with BuildKit
DOCKER_BUILDKIT=1 docker build -t app .

# Build with cache export
docker build --cache-from type=registry,ref=app:cache -t app .

# Run with security options
docker run --cap-drop=ALL --read-only --user 1000:1000 app

# Scan image
trivy image app:latest

# Lint Dockerfile
hadolint Dockerfile

# Multi-platform build
docker buildx build --platform linux/amd64,linux/arm64 -t app --push .

# Compose with profile
docker compose --profile dev up -d
```

### Resource checklist

- [ ] Using specific base image tag
- [ ] Multi-stage build implemented
- [ ] Non-root user configured
- [ ] HEALTHCHECK defined
- [ ] .dockerignore present
- [ ] No secrets in image
- [ ] Security scanning enabled
- [ ] Cache mounts for package managers
- [ ] Minimal runtime dependencies
- [ ] Hadolint passing
