#!/usr/bin/env bash
set -euo pipefail

# Requires Git and Go 1.26 or newer. Outputs are written beside this script.
cd -- "$(dirname -- "${BASH_SOURCE[0]}")"
build_dir=$(mktemp -d)
trap 'rm -rf "$build_dir"' EXIT

git clone --depth 1 --branch naive \
  https://github.com/klzgrad/forwardproxy.git "$build_dir/forwardproxy"
caddy_version=$(<"$build_dir/forwardproxy/CADDY_VERSION")

git clone --depth 1 --branch "$caddy_version" \
  https://github.com/caddyserver/caddy.git "$build_dir/caddy"
git -C "$build_dir/caddy" apply \
  "$build_dir/forwardproxy/caddy-sing-quic-bbrv1.patch" \
  "$build_dir/forwardproxy/caddy-read-idle-timeout.patch"

GOBIN="$build_dir/bin" go install github.com/caddyserver/xcaddy/cmd/xcaddy@latest

for arch in amd64 arm64; do
  env CGO_ENABLED=0 GOOS=linux GOARCH="$arch" "$build_dir/bin/xcaddy" build "$caddy_version" \
    --replace "github.com/caddyserver/caddy/v2=$build_dir/caddy" \
    --with github.com/caddy-dns/cloudflare \
    --with github.com/mholt/caddy-webdav \
    --with "github.com/caddyserver/forwardproxy=$build_dir/forwardproxy" \
    --output "caddy_${arch}"
done
