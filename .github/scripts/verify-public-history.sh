#!/usr/bin/env bash
set -euo pipefail

readonly base_ref="${1:?base commit is required}"
git rev-parse --verify --quiet "${base_ref}^{commit}" >/dev/null
git diff --check "${base_ref}..HEAD"

readonly version='8.30.1'
readonly checksum='551f6fc83ea457d62a0d98237cbad105af8d557003051f41f3e7ca7b3f2470eb'
scan_dir="$(mktemp -d "${TMPDIR:-/tmp}/gitleaks-public-history.XXXXXX")"
trap 'rm -rf -- "$scan_dir"' EXIT
readonly archive="$scan_dir/gitleaks.tar.gz"
curl --proto '=https' --tlsv1.2 --fail --silent --show-error --location \
  --output "$archive" \
  "https://github.com/gitleaks/gitleaks/releases/download/v${version}/gitleaks_${version}_linux_x64.tar.gz"
printf '%s  %s\n' "$checksum" "$archive" | sha256sum --check --status
tar -xzf "$archive" -C "$scan_dir" gitleaks
"$scan_dir/gitleaks" git --redact --no-banner --exit-code 1 --log-opts='--all' .
test "$(git status --porcelain=v1 --untracked-files=all)" = ''
printf 'post-commit public history gate: PASS\n'
