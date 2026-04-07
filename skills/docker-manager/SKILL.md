---
name: docker-manager
description: Manage Docker containers, images, and basic operations. Use when building images from Dockerfiles, running containers, viewing logs, managing container lifecycle, inspecting running containers, cleaning up resources, or deploying containerized applications.
allowed-tools: Bash, Read, Glob
---

# Docker Manager

Expert Docker container and image management skill. Provides essential commands for the complete Docker workflow from building to deployment.

## Container Lifecycle Management

### Running Containers

**Start a new container:**
```bash
docker run [OPTIONS] IMAGE [COMMAND]
```

Common options:
- `-d, --detach`: Run container in background
- `-p, --publish`: Publish container port to host (e.g., `-p 8080:80`)
- `--name`: Assign a name to the container
- `--rm`: Automatically remove container when it exits
- `-e, --env`: Set environment variables
- `-v, --volume`: Bind mount a volume (e.g., `-v /host/path:/container/path`)
- `-it`: Interactive terminal (combine `-i` and `-t`)
- `--network`: Connect to a network

```bash
# Run nginx in background, map port 8080 to 80
docker run -d -p 8080:80 --name my-nginx nginx

# Run interactive shell with auto-cleanup
docker run -it --rm ubuntu bash
```

### Managing Running Containers

**Start/stop/restart containers:**
```bash
docker start CONTAINER     # Start stopped container
docker stop CONTAINER      # Stop running container (SIGTERM then SIGKILL)
docker restart CONTAINER   # Restart container
docker pause CONTAINER     # Pause container processes
docker unpause CONTAINER   # Unpause container
```

**Remove containers:**
```bash
docker rm CONTAINER              # Remove stopped container
docker rm -f CONTAINER           # Force remove running container
docker container prune           # Remove all stopped containers
docker container prune -f        # Remove without confirmation
```

### Listing Containers

```bash
docker ps                   # List running containers
docker ps -a                # List all containers (running + stopped)
docker ps -q                # List container IDs only
docker ps --filter status=exited  # Filter by status
docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Status}}"  # Custom format
```

## Image Management

### Building Images

**Build from Dockerfile:**
```bash
docker build [OPTIONS] PATH

# Common options:
-t, --tag        # Name and optionally tag (name:tag)
--no-cache       # Build without using cache
--build-arg      # Set build-time variables
-f, --file       # Specify Dockerfile location
--target         # Set target build stage (multi-stage builds)
```

```bash
docker build -t myapp:latest .
docker build -t myapp --no-cache --build-arg VERSION=1.0 .
docker build -t myapp -f docker/Dockerfile.prod .
```

### Managing Images

**List and inspect images:**
```bash
docker images               # List all images
docker images -q            # List image IDs only
docker image ls --filter dangling=true  # List untagged images
docker image inspect IMAGE  # Show detailed image information
```

**Pull and push images:**
```bash
docker pull IMAGE[:TAG]           # Download image from registry
docker push IMAGE[:TAG]           # Upload image to registry
docker tag SOURCE_IMAGE[:TAG] TARGET_IMAGE[:TAG]  # Create image tag

# Example: tag and push to registry
docker tag myapp:latest username/myapp:v1.0
docker login && docker push username/myapp:v1.0
```

**Remove images:**
```bash
docker rmi IMAGE            # Remove image
docker rmi -f IMAGE         # Force remove image
docker image prune          # Remove dangling images
docker image prune -a       # Remove all unused images
```

## Inspection and Debugging

### Container Logs

```bash
docker logs CONTAINER          # Show container logs
docker logs -f CONTAINER       # Follow log output (like tail -f)
docker logs --tail 100 CONTAINER  # Show last 100 lines
docker logs --since 30m CONTAINER # Logs from last 30 minutes
docker logs -t CONTAINER       # Show timestamps
```

### Execute Commands in Running Container

```bash
docker exec [OPTIONS] CONTAINER COMMAND

# Common options:
-it              # Interactive terminal
-u, --user       # Run as specific user
-w, --workdir    # Working directory
-e, --env        # Set environment variables
```

```bash
docker exec -it my-container bash
docker exec -it -u root my-container bash
docker exec -w /app my-container python manage.py migrate
```

### Container Inspection

```bash
docker inspect CONTAINER    # Show detailed container info (JSON)
docker stats                # Live resource usage stats for all containers
docker stats CONTAINER      # Stats for specific container
docker top CONTAINER        # Show running processes in container
docker port CONTAINER       # List port mappings
```

**Useful inspect queries (using --format):**
```bash
# Get container IP address
docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' CONTAINER

# Get container status
docker inspect -f '{{.State.Status}}' CONTAINER

# Get mount points
docker inspect -f '{{json .Mounts}}' CONTAINER | python -m json.tool
```

## System Management and Cleanup

### Disk Usage

```bash
docker system df            # Show Docker disk usage
docker system df -v         # Verbose output with details
```

### Cleanup Operations

```bash
# Remove stopped containers
docker container prune
docker container prune -f   # Skip confirmation

# Remove unused images
docker image prune          # Remove dangling images
docker image prune -a       # Remove all unused images
docker image prune -a -f    # Force remove without confirmation

# Remove unused volumes
docker volume prune
docker volume prune -f

# Remove unused networks
docker network prune

# Clean everything unused (containers, images, networks, volumes)
docker system prune
docker system prune -a      # Include all unused images
docker system prune -a -f --volumes  # Nuclear option: remove everything unused
```

### Docker Info

```bash
docker version              # Show Docker version info
docker info                 # Display system-wide information
```

## Volume Management

```bash
docker volume create VOLUME       # Create volume
docker volume ls                  # List volumes
docker volume inspect VOLUME      # Inspect volume
docker volume rm VOLUME           # Remove volume
docker volume prune               # Remove unused volumes
```

**Using volumes with containers:**
```bash
# Named volume
docker run -v mydata:/app/data myapp

# Bind mount (host path)
docker run -v /host/path:/container/path myapp

# Read-only volume
docker run -v mydata:/app/data:ro myapp
```

## Network Management

```bash
docker network ls                 # List networks
docker network create NETWORK     # Create network
docker network inspect NETWORK    # Inspect network
docker network rm NETWORK         # Remove network
docker network connect NETWORK CONTAINER    # Connect container to network
docker network disconnect NETWORK CONTAINER # Disconnect container
```

## Best Practices

### Security
- Don't run containers as root when possible (use `--user` flag)
- Use specific image tags, not `latest` in production
- Scan images for vulnerabilities: `docker scan IMAGE`
- Use `.dockerignore` to exclude sensitive files from builds
- Never store secrets in images or environment variables

### Performance
- Use multi-stage builds to reduce image size
- Leverage build cache by ordering Dockerfile commands properly
- Use `--no-cache` only when necessary
- Clean up unused resources regularly with `prune` commands
- Use volumes for persistent data, not container filesystem

### Development Workflow
- Use descriptive container and image names
- Tag images with version numbers
- Use `docker compose` for multi-container applications
- Keep Dockerfiles in version control
- Document required environment variables

## Docker Compose

Manage multi-container applications with Docker Compose.

### Basic Commands

```bash
docker compose up                 # Start services
docker compose up -d              # Start in background
docker compose up --build         # Rebuild images and start
docker compose down               # Stop and remove containers
docker compose down -v            # Also remove volumes
docker compose down --remove-orphans  # Clean up old services
```

### Service Management

```bash
# Build services
docker compose build              # Build all
docker compose build service      # Build specific service

# Control services
docker compose start/stop/restart [service]
docker compose ps                 # List services
docker compose logs -f [service]  # Follow logs

# Execute commands in services
docker compose exec service command        # Interactive
docker compose exec -T service command     # Non-interactive (scripts/CI)
docker compose exec -u root service bash   # As specific user
```

### Multiple Compose Files

```bash
# Use specific file
docker compose -f docker-compose.dev.yml up

# Merge multiple files (base + environment)
docker compose -f compose.yml -f compose.dev.yml up
docker compose -f compose.yml -f compose.prod.yml up -d
```

### Common Patterns

```bash
# Development: rebuild and start
docker compose -f compose.dev.yml up --build -d

# View specific service logs
docker compose logs -f backend

# Run Django migrations
docker compose exec -T backend python manage.py migrate

# Run tests
docker compose exec -T backend pytest

# Scale services
docker compose up -d --scale worker=3

# Fresh restart
docker compose down -v --remove-orphans
docker compose up --build -d
```

## Script Execution in Containers

Execute scripts and commands inside running containers.

### Interactive vs Non-Interactive

```bash
# Interactive (debugging, shells)
docker exec -it container bash
docker compose exec service bash

# Non-interactive (scripts, CI/CD, pipes)
docker exec -T container command
docker compose exec -T service command
```

**Use `-T` when:**
- Running in CI/CD pipelines
- Piping input/output
- Getting "not a TTY" errors

### Shell Scripts

```bash
# Pipe script from host
docker exec -T container bash < script.sh
docker compose exec -T service bash < init.sh

# Execute script in container
docker exec container /app/scripts/setup.sh

# Multi-line script
docker exec container bash -c 'cd /app && source venv/bin/activate && python manage.py migrate'
```

### Python Execution

```bash
# Run Python script
docker compose exec backend python scripts/process.py

# Run module
docker compose exec -T backend python -m pytest

# Django commands
docker compose exec -T backend python manage.py migrate
docker compose exec backend python manage.py shell
docker compose exec backend python manage.py createsuperuser

# Flask commands
docker compose exec backend flask db upgrade
docker compose exec backend flask shell
```

### JavaScript/Node Execution

```bash
# Run Node script
docker compose exec frontend node scripts/build.js

# NPM commands
docker compose exec frontend npm run build
docker compose exec -T frontend npm test
docker compose exec frontend npm run dev
```

### Database Operations

```bash
# PostgreSQL
docker compose exec db psql -U user -d database
docker compose exec -T db psql -U user -d database -c "SELECT * FROM users;"
docker compose exec -T db pg_dump -U user database > backup.sql

# MySQL
docker compose exec db mysql -u user -ppass database
docker compose exec -T db mysqldump -u user -ppass database > backup.sql

# Restore
cat backup.sql | docker compose exec -T db psql -U user database
```

### Running Tests

```bash
# Python
docker compose exec -T backend pytest
docker compose exec -T backend pytest -v tests/unit/

# JavaScript
docker compose exec -T frontend npm test
docker compose exec -T frontend npm test -- --coverage
```

## Troubleshooting

**Container won't start:**
```bash
# Check logs for errors
docker logs container-name

# Inspect container configuration
docker inspect container-name

# Try running interactively to see errors
docker run -it --entrypoint /bin/bash image-name
```

**Port already in use:**
```bash
# Find what's using the port
sudo lsof -i :8080

# Or use different host port
docker run -p 8081:80 image-name
```

**Out of disk space:**
```bash
# Check usage
docker system df

# Clean up aggressively
docker system prune -a -f --volumes
```

**Permission denied errors:**
```bash
# Add user to docker group (Linux)
sudo usermod -aG docker $USER
# Then log out and back in
```

**Compose service failures:**
```bash
# Check service dependencies
docker compose config

# View specific service status
docker compose ps service

# Check if health checks are failing
docker inspect $(docker compose ps -q service)
```

**Volume permission issues:**
```bash
# Run command as root to fix permissions
docker compose exec -u root service chown -R appuser:appuser /data

# Or set user in docker-compose.yml
services:
  app:
    user: "1000:1000"
```

Use this skill for all Docker container, image, and multi-container application management tasks.
