#!/usr/bin/env bash

set -euo pipefail

readonly REPO_OWNER="ukondoby"
readonly REPO_NAME="bootstrap"
readonly REPO_COMMIT="${BOOTSTRAP_COMMIT:-}"
readonly ARCHIVE_SHA256="${BOOTSTRAP_SHA256:-}"

TMP_DIR=""

cleanup() {
    if [[ -n "${TMP_DIR:-}" && -d "$TMP_DIR" ]]; then
        rm -rf "$TMP_DIR"
    fi
}

trap cleanup EXIT

main() {
    [[ "$REPO_COMMIT" =~ ^[0-9a-f]{40}$ ]] || {
        printf 'error: BOOTSTRAP_COMMIT must be a full 40-character commit SHA\n' >&2
        exit 1
    }

    [[ "$ARCHIVE_SHA256" =~ ^[0-9a-f]{64}$ ]] || {
        printf 'error: BOOTSTRAP_SHA256 must be the trusted SHA-256 of the commit archive\n' >&2
        exit 1
    }

    command -v curl >/dev/null 2>&1 || {
        printf 'error: curl is required\n' >&2
        exit 1
    }

    command -v tar >/dev/null 2>&1 || {
        printf 'error: tar is required\n' >&2
        exit 1
    }

    command -v sha256sum >/dev/null 2>&1 || {
        printf 'error: sha256sum is required\n' >&2
        exit 1
    }

    TMP_DIR="$(mktemp -d)"

    printf '==> Downloading bootstrap repository\n'

    local archive_url
    archive_url="https://gitlab.com/${REPO_OWNER}/${REPO_NAME}/-/archive/${REPO_COMMIT}/${REPO_NAME}-${REPO_COMMIT}.tar.gz"

    curl -fsSL \
        "$archive_url" \
        -o "${TMP_DIR}/bootstrap.tar.gz"

    printf '==> Verifying bootstrap archive\n'

    printf '%s  %s\n' \
        "$ARCHIVE_SHA256" \
        "${TMP_DIR}/bootstrap.tar.gz" \
        | sha256sum -c - >/dev/null

    printf '==> Extracting verified bootstrap repository\n'

    local repo_dir
    repo_dir="${TMP_DIR}/repo"
    mkdir -p "$repo_dir"

    tar -xzf \
        "${TMP_DIR}/bootstrap.tar.gz" \
        --strip-components=1 \
        -C "$repo_dir"

    [[ -x "${repo_dir}/install.sh" ]] || {
        printf 'error: install.sh not found or not executable\n' >&2
        exit 1
    }

    printf '==> Starting installer\n'

    "${repo_dir}/install.sh"
}

main "$@"
