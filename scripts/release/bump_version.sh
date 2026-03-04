#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
VERSION_FILE="${ROOT_DIR}/VERSION"
BRANCH_DIR="${ROOT_DIR}/.versioning/branches"

BRANCH_NAME="${BRANCH_NAME:-}"
BEFORE_SHA="${BEFORE_SHA:-}"
AFTER_SHA="${AFTER_SHA:-HEAD}"
MAJOR_BUMP="${MAJOR_BUMP:-false}"

if [[ -z "$BRANCH_NAME" ]]; then
  echo "BRANCH_NAME is required" >&2
  exit 1
fi

mkdir -p "$BRANCH_DIR"

if [[ -f "$VERSION_FILE" ]]; then
  CURRENT_VERSION="$(tr -d '[:space:]' < "$VERSION_FILE")"
else
  CURRENT_VERSION="0.0.0"
fi

if [[ ! "$CURRENT_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Invalid VERSION format: ${CURRENT_VERSION}" >&2
  exit 1
fi

IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VERSION"

sanitize_branch() {
  echo "$1" | tr '/[:space:]' '__' | tr -cd '[:alnum:]_.-'
}

branch_key="$(sanitize_branch "$BRANCH_NAME")"
branch_marker="${BRANCH_DIR}/${branch_key}.created"

commit_count_between() {
  local before="$1"
  local after="$2"

  if [[ -z "$before" || "$before" =~ ^0+$ ]]; then
    echo "1"
    return 0
  fi

  git rev-list --count "${before}..${after}"
}

COMMITS_COUNT="$(commit_count_between "$BEFORE_SHA" "$AFTER_SHA")"
if [[ -z "$COMMITS_COUNT" || "$COMMITS_COUNT" -lt 1 ]]; then
  COMMITS_COUNT=1
fi

if [[ "$MAJOR_BUMP" == "true" ]]; then
  MAJOR=$((MAJOR + 1))
  MINOR=0
  PATCH=0
else
  if [[ "$BRANCH_NAME" != "main" && ! -f "$branch_marker" ]]; then
    MINOR=$((MINOR + 1))
    PATCH=0
  else
    PATCH=$((PATCH + COMMITS_COUNT))
  fi
fi

NEW_VERSION="${MAJOR}.${MINOR}.${PATCH}"
echo "$NEW_VERSION" > "$VERSION_FILE"

if [[ ! -f "$branch_marker" ]]; then
  {
    echo "branch=${BRANCH_NAME}"
    echo "created_at=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  } > "$branch_marker"
fi

echo "version=${NEW_VERSION}"
