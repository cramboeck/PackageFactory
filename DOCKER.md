# 🐳 Package Factory v2.0 - Docker Edition

**Run Package Factory in Docker - No PowerShell version issues!**

---

## 🌟 Why Docker?

### ✅ Advantages
- ✅ **No PowerShell version conflicts** - Always runs PowerShell 7
- ✅ **No Pode installation needed** - Everything in container
- ✅ **Cross-platform** - Works on Windows, Linux, macOS
- ✅ **Consistent environment** - Same everywhere
- ✅ **Easy updates** - Just rebuild container
- ✅ **Isolated** - Doesn't affect host system

### 📦 What's Included
- PowerShell 7 (latest)
- Pode Web Server
- Package Factory v2.0
- All dependencies

---

## 🚀 Quick Start (3 Steps)

### Step 1: Install Docker

**Windows:**
```
Download: https://www.docker.com/products/docker-desktop
Install Docker Desktop
```

**Linux:**
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
```

**macOS:**
```
Download: https://www.docker.com/products/docker-desktop
Install Docker Desktop
```

### Step 2: Start Container

**Option A: Using docker-compose (Recommended)**
```bash
docker-compose up -d
```

**Option B: Using Batch File (Windows)**
```
Double-click: Start-Docker.bat
```

**Option C: Manual Docker Command**
```bash
docker build -t packagefactory:v2 .
docker run -d -p 8080:8080 -v ./Output:/app/Output -v ./Config:/app/Config packagefactory:v2
```

### Step 3: Open Browser

```
http://localhost:8080
```

**That's it! 🎉**

---

## 📋 Docker Commands

### Start Container
```bash
# With docker-compose (recommended)
docker-compose up -d

# Or with docker
docker run -d -p 8080:8080 --name packagefactory packagefactory:v2
```

### Stop Container
```bash
docker-compose down

# Or
docker stop packagefactory
```

### View Logs
```bash
docker-compose logs -f

# Or
docker logs -f packagefactory
```

### Restart Container
```bash
docker-compose restart

# Or
docker restart packagefactory
```

### Rebuild Container
```bash
docker-compose build --no-cache
docker-compose up -d
```

### Remove Container
```bash
docker-compose down -v

# Or
docker rm -f packagefactory
```

---

## 🗂️ Volume Mapping

Docker containers use volumes to persist data:

| Host Path | Container Path | Description |
|-----------|---------------|-------------|
| `./Output` | `/app/Output` | Generated packages |
| `./Config` | `/app/Config` | Settings (settings.json) |
| `./Generator/Templates` | `/app/Generator/Templates` | Custom templates |

### Access Generated Packages
```
Host: .\Output\{PackageName}\
Container: /app/Output/{PackageName}/
```

Packages created in the container appear in your **local Output folder**!

---

## ⚙️ Configuration

### Default Port: 8080

Change port in **docker-compose.yml**:
```yaml
ports:
  - "9090:8080"  # Host:Container
```

Or with docker command:
```bash
docker run -p 9090:8080 packagefactory:v2
```

Then open: `http://localhost:9090`

### Environment Variables

Edit **docker-compose.yml**:
```yaml
environment:
  - TZ=Europe/Vienna       # Timezone
  - ASPNETCORE_URLS=http://+:8080
```

### Settings

Edit **Config/settings.json** on host machine:
```json
{
  "CompanyPrefix": "MSP",
  "DefaultArch": "x64",
  "DefaultLang": "EN",
  "IncludePSADT": true
}
```

Changes are immediately available in container!

---

## 🔧 Advanced Usage

### Build Custom Image

```bash
# Build with custom tag
docker build -t my-packagefactory:latest .

# Build with specific PowerShell version
docker build --build-arg PS_VERSION=7.4.0 -t packagefactory:v2 .
```

### Run with Custom Settings

```bash
docker run -d \
  -p 8080:8080 \
  -v $(pwd)/Output:/app/Output \
  -v $(pwd)/Config:/app/Config \
  -e TZ=America/New_York \
  --name packagefactory \
  packagefactory:v2
```

### Shell Access to Container

```bash
# PowerShell shell
docker exec -it packagefactory pwsh

# Inside container you can:
cd /app
ls Output/
cat Config/settings.json
```

### Copy Files from Container

```bash
# Copy generated package
docker cp packagefactory:/app/Output/Adobe_Reader_24.1.0_x64 ./

# Copy logs
docker logs packagefactory > packagefactory.log
```

---

## 🐛 Troubleshooting

### Container won't start

**Check logs:**
```bash
docker logs packagefactory
```

**Check if port is free:**
```bash
# Windows
netstat -ano | findstr :8080

# Linux/Mac
lsof -i :8080
```

**Rebuild:**
```bash
docker-compose down
docker-compose build --no-cache
docker-compose up
```

### Can't access http://localhost:8080

**Check if container is running:**
```bash
docker ps
```

**Check port mapping:**
```bash
docker port packagefactory
# Should show: 8080/tcp -> 0.0.0.0:8080
```

**Check from inside container:**
```bash
docker exec packagefactory pwsh -Command "Invoke-WebRequest http://localhost:8080 -UseBasicParsing"
```

### Volume permissions (Linux)

```bash
# Fix permissions
sudo chown -R $USER:$USER Output/ Config/
```

### Container keeps restarting

```bash
# Check what's wrong
docker logs --tail 50 packagefactory

# Stop restart policy
docker update --restart=no packagefactory
```

---

## 📊 Container Info

### Image Size
- **Base Image:** ~300 MB (PowerShell 7 on Linux)
- **With Pode:** ~310 MB
- **Total:** ~310 MB

### Resource Usage
- **RAM:** ~100 MB
- **CPU:** Minimal (idle)
- **Disk:** ~310 MB (image) + generated packages

### Health Check
Docker automatically checks if server is responsive:
```bash
docker inspect packagefactory | grep -A 5 Health
```

---

## 🔒 Security

### Container Isolation
- ✅ Runs as non-root user
- ✅ Only port 8080 exposed
- ✅ No host network access
- ✅ Isolated filesystem

### Network
```yaml
# Default: Bridge network (isolated)
networks:
  - packagefactory-net
```

### Firewall
Only port 8080 is exposed. To access from network:
```yaml
ports:
  - "0.0.0.0:8080:8080"  # All interfaces
```

**Warning:** Only do this in trusted networks!

---

## 🔄 Updates

### Update to New Version

```bash
# Pull new version
git pull

# Rebuild container
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

### Update PowerShell/Pode

```bash
# Rebuild with latest base image
docker-compose build --pull --no-cache
docker-compose up -d
```

---

## 📦 Distribution

### Export Container Image

```bash
# Save image
docker save packagefactory:v2 | gzip > packagefactory-v2.tar.gz

# Transfer to another machine

# Load image
docker load < packagefactory-v2.tar.gz
```

### Share docker-compose.yml

Just share the entire folder:
```
PackageFactory_v2.0_Portable/
├── Dockerfile
├── docker-compose.yml
├── Start-Docker.bat
└── ... (all files)
```

---

## 🆚 Docker vs. Native

| Feature | Native | Docker |
|---------|--------|--------|
| PowerShell Version | Must be 5.1+ | Always 7+ ✅ |
| Pode Installation | Manual | Auto ✅ |
| Cross-platform | Windows only | All platforms ✅ |
| Setup Time | 5 min | 2 min ✅ |
| Resource Usage | Lower ✅ | ~100 MB RAM |
| Portability | Medium | High ✅ |
| Updates | Manual | Easy ✅ |

---

## 💡 Tips & Tricks

### Auto-start on Boot
```bash
# docker-compose.yml already has:
restart: unless-stopped
```

### Custom Templates in Docker
```bash
# Add custom template to Generator/Templates/
# It's automatically mounted via volume!
```

### Backup
```bash
# Backup everything
tar -czf packagefactory-backup.tar.gz Output/ Config/
```

### Multiple Instances
```bash
# Run second instance on port 9090
docker run -d -p 9090:8080 --name packagefactory2 packagefactory:v2
```

---

## 🎓 Docker Compose Commands Reference

```bash
# Start (detached)
docker-compose up -d

# Start (foreground with logs)
docker-compose up

# Stop
docker-compose down

# Restart
docker-compose restart

# View logs
docker-compose logs -f

# Build
docker-compose build

# Build without cache
docker-compose build --no-cache

# Pull latest base images
docker-compose pull

# Show running services
docker-compose ps

# Execute command in container
docker-compose exec packagefactory pwsh

# Remove everything (including volumes!)
docker-compose down -v
```

---

## 📞 Support

**Issues with Docker?**
- Check Docker logs: `docker logs packagefactory`
- Verify Docker is running: `docker ps`
- Check Docker version: `docker --version`

**Still having problems?**
- Email: c@ramboeck.it
- Include: Docker version, OS, error messages

---

## 🎉 Ready to Use!

```bash
# Clone/Download Package Factory
cd PackageFactory_v2.0_Portable

# Start with Docker
docker-compose up -d

# Open browser
http://localhost:8080

# Create packages!
```

**Simple. Portable. Dockerized. 🐳**

---

**© 2025 Ramböck IT - Package Factory v2.0 Docker Edition**
