# Package Factory v2.0 - Docker Edition
# Based on PowerShell 7 (Linux)

FROM mcr.microsoft.com/powershell:latest

# Metadata
LABEL maintainer="Christoph Ramboeck <c@ramboeck.it>"
LABEL description="Package Factory v2.0 - Portable Autopilot Package Generator"
LABEL version="2.0.1"

# Set working directory
WORKDIR /app

# Install Pode module first (cached layer)
RUN pwsh -Command "Install-Module -Name Pode -Force -Scope CurrentUser -AcceptLicense"

# Create directories for volumes (cached layer)
RUN mkdir -p /app/Output /app/Modules

# Build argument to break cache when needed
ARG CACHEBUST=1

# Copy application files (this layer will be rebuilt when CACHEBUST changes)
COPY WebServer/ ./WebServer/
COPY Generator/ ./Generator/
COPY Config/ ./Config/
COPY Start-PackageFactory.ps1 ./
COPY QUICKSTART.md README.md CHANGELOG.md STRUCTURE.md TROUBLESHOOTING.md ./

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD pwsh -Command "try { Invoke-WebRequest -Uri http://localhost:8080 -UseBasicParsing -TimeoutSec 2 | Out-Null; exit 0 } catch { exit 1 }"

# Set entrypoint
ENTRYPOINT ["pwsh", "-File", "/app/WebServer/Server.ps1", "-Port", "8080", "-RootPath", "/app"]
