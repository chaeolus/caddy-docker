# Caddy Custom Build with GitHub Actions

This repository provides automated build workflows for Caddy web server with custom plugins, targeting Linux platforms.

## Features

- 🤖 Automated daily builds using GitHub Actions
- 🐳 Multi-architecture Docker images (amd64, arm64)
- Pre-configured with popular plugins:
  - Cloudflare DNS provider
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

Download the Linux executable from the [latest GitHub Release](https://github.com/chaeolus/caddy-docker/releases/tag/latest):

- `caddy_amd64` (for x86-64 Linux systems)
- `caddy_arm64` (for ARM64 Linux devices)

Make it executable and run:

```bash
chmod +x caddy_amd64
./caddy_amd64 run --config Caddyfile
```

Use `caddy_arm64` instead on ARM64 Linux.

## Manual Build

### Requirements

- Bash and standard shell utilities, including `mktemp`.
- Git and Go 1.26 or newer, available on `PATH`.
- Network access to GitHub and Go module/toolchain downloads.

The script installs xcaddy into a temporary directory automatically.

### Build Commands

```bash
git clone https://github.com/chaeolus/caddy-docker.git
cd caddy-docker
bash ./build.sh
```

If you already have a checkout, run `bash ./build.sh` from the repository root.
Each invocation rebuilds both Linux architectures, including when only the plugin has changed.

The resulting static binaries are written to the repository root:

- `caddy_amd64`: Linux x86-64.
- `caddy_arm64`: Linux ARM64.

Run each binary on a matching Linux system using the commands above.

### Patched Caddy Build Process

Manual builds and GitHub Actions use the same `build.sh` script:

1. Check out the latest `naive` branch of `klzgrad/forwardproxy` into a temporary directory.
2. Read the plugin's `CADDY_VERSION` file and check out that compatible Caddy version.
3. Apply both upstream patches: `caddy-sing-quic-bbrv1.patch` and `caddy-read-idle-timeout.patch`.
4. Install xcaddy and use `--replace` for the patched Caddy source and `--with` for the checked-out forwardproxy source, alongside Cloudflare DNS and WebDAV.
5. Compile Linux `amd64` and `arm64` binaries with `CGO_ENABLED=0`, then clean up temporary source checkouts and xcaddy when the script exits.

The idle-timeout patch supplies the `caddyhttp.IdleTimeoutsFromContext` API required by the current plugin. Using the plugin with unpatched Caddy can fail to compile with an undefined-function error. The Caddy version and patches are taken from the same plugin checkout to keep them compatible; see the [upstream build workflow](https://github.com/klzgrad/forwardproxy/blob/naive/.github/workflows/build.yml).

GitHub Actions runs this script with Go 1.26, checks the amd64 binary's version and module list, uploads both binaries, and publishes the multi-architecture Docker image and GitHub Release. The workflow's JavaScript actions use Node.js 24.

## Plugins Included

- `github.com/caddy-dns/cloudflare` - Cloudflare DNS provider for automatic HTTPS
- `github.com/mholt/caddy-webdav` - WebDAV support for file sharing
- `github.com/klzgrad/forwardproxy@naive` - Forward proxy with Naive implementation

## Customization

### Adding More Plugins

Add additional plugins to the xcaddy command in `build.sh`; GitHub Actions uses the same script:

```bash
--with github.com/your-favorite-plugin
```

### Changing Build Schedule

Modify the `cron` expression in `.github/workflows/build.yml` to change the build frequency.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
