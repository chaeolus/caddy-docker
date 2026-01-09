# Caddy Custom Build with GitHub Actions

This repository provides automated build workflows for Caddy web server with custom plugins, targeting Linux platforms.

## Features

- 🤖 Automated daily builds using GitHub Actions
- 🐳 Multi-architecture Docker images (amd64, arm64)
- Pre-configured with popular plugins:
  - Cloudflare DNS provider
  - Caddy L4 (TCP/UDP proxy)
  - WebDAV support
  - Forward proxy with Naive implementation

## Docker Usage

### Run Container

```bash
docker run -d \
  -p 80:80 \
  -p 443:443 \
  -v $PWD/Caddyfile:/etc/caddy/Caddyfile \
  ghcr.io/chaeolus/caddy-docker:latest
```

## Linux Binary Usage

Download the Linux executable from the GitHub Releases page:

- `caddy_linux_amd64` (for most Linux systems)
- `caddy_linux_arm64` (for ARM64 Linux devices)

Make it executable and run:

```bash
chmod +x caddy_linux_amd64
./caddy_linux_amd64 run --config Caddyfile
```

## Plugins Included

- `github.com/caddy-dns/cloudflare` - Cloudflare DNS provider for automatic HTTPS
- `github.com/mholt/caddy-l4` - Layer 4 TCP/UDP proxy support
- `github.com/mholt/caddy-webdav` - WebDAV support for file sharing
- `github.com/klzgrad/forwardproxy@naive` - Forward proxy with Naive implementation

## Customization

### Adding More Plugins

Edit the build script or GitHub Actions workflow to include additional plugins:

```bash
--with github.com/your-favorite-plugin
```

### Changing Build Schedule

Modify the `cron` expression in `.github/workflows/build.yml` to change the build frequency.

## License

This project is licensed under the MIT License - see the LICENSE file for details.