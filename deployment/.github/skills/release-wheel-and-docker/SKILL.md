---
name: release-wheel-and-docker
description: Build a Python wheel and (optionally) a source distribution using python -m build, then build a Docker image that uses the wheel. Use when preparing releases, validating packaging, or standardizing build commands for Python projects.
license: MIT
---

# Release: wheel + docker image

## Purpose

Build distributable artifacts:
- Python wheel (`.whl`) for pip installation
- Source distribution (`.tar.gz`) for source installation
- Docker image for containerized deployment

## Wheel build

### Using python-build (recommended)

```bash
# Install build tool
uv add --dev build

# Build wheel and sdist
python -m build

# Build wheel only
python -m build --wheel

# Build sdist only
python -m build --sdist
```

### Using uv (alternative)

```bash
# Build with uv
uv build

# Artifacts in dist/
ls dist/
# {project_name}-0.9.10-py3-none-any.whl
# {project_name}-0.9.10.tar.gz
```

## Project configuration

### pyproject.toml (hatch backend)

```toml
[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[tool.hatch.build.targets.wheel]
packages = ["src/{project_package}"]

[tool.hatch.build.targets.sdist]
include = [
    "src/",
    "tests/",
    "README.md",
    "pyproject.toml",
]
```

### MANIFEST.in (if needed)

```
include README.md
include LICENSE
include pyproject.toml
recursive-include src/{project_package} *.py *.html *.css *.js
recursive-exclude tests *
```

## Docker build

### Basic Dockerfile

```dockerfile
FROM python:3.13-slim

WORKDIR /app

# Copy and install wheel
COPY dist/{project_name}-*.whl .
RUN pip install --no-cache-dir {project_name}-*.whl && rm {project_name}-*.whl

# Copy entrypoint
COPY docker-entrypoint.sh .
RUN chmod +x docker-entrypoint.sh

EXPOSE 8000
ENTRYPOINT ["./docker-entrypoint.sh"]
```

### Multi-stage build

```dockerfile
# Build stage
FROM python:3.13 AS builder
WORKDIR /build
COPY . .
RUN pip install build && python -m build --wheel

# Runtime stage
FROM python:3.13-slim
WORKDIR /app
COPY --from=builder /build/dist/*.whl .
RUN pip install --no-cache-dir *.whl && rm *.whl
```

### Build commands

```bash
# Build Docker image
docker build -t {project_name}:latest .

# Build with version tag
docker build -t {project_name}:0.9.10 .

# Build and tag for registry
docker build -t registry.example.com/{project_name}:0.9.10 .
```

## Docker Compose (development)

```yaml
# docker-compose.yml
services:
  {project_name}:
    build: .
    ports:
      - "8000:8000"
    environment:
      - {PROJECT_PREFIX}_DEBUG=false
    volumes:
      - ./data:/app/data
```

## Validation steps

```bash
# Verify wheel contents
unzip -l dist/{project_name}-*.whl

# Test wheel installation
pip install dist/{project_name}-*.whl
{project_name} --version

# Test Docker image
docker run --rm {project_name}:latest {project_name} --version
```

## CI/CD integration

### GitHub Actions example

```yaml
- name: Build wheel
  run: python -m build

- name: Build Docker image
  run: docker build -t {project_name}:${{ github.sha }} .

- name: Push to registry
  run: docker push registry.example.com/{project_name}:${{ github.sha }}
```

## Reporting requirements

Always report:
- `dist/` artifacts created (filenames and sizes)
- Docker image tag(s) built
- Any build warnings or isolation issues
- Missing system dependencies discovered
