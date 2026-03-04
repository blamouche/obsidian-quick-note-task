#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
RELEASES_FILE="${ROOT_DIR}/Releases.md"
CURRENT_VERSION="${1:-}"

if [[ -z "$CURRENT_VERSION" ]]; then
  echo "Usage: $0 <current-version>" >&2
  exit 1
fi

TODAY_UTC="$(date -u +%Y-%m-%d)"

read_tags() {
  local sort="$1"
  local tag
  while IFS= read -r tag; do
    [[ -n "$tag" ]] && echo "$tag"
  done < <(git tag --list '0.0.*' --sort="$sort")
}

TAGS_ASC=()
while IFS= read -r tag; do
  TAGS_ASC+=("$tag")
done < <(read_tags "v:refname")

TAGS_DESC=()
while IFS= read -r tag; do
  TAGS_DESC+=("$tag")
done < <(read_tags "-v:refname")

VERSIONS_DESC=("$CURRENT_VERSION")
for tag in "${TAGS_DESC[@]}"; do
  if [[ "$tag" != "$CURRENT_VERSION" ]]; then
    VERSIONS_DESC+=("$tag")
  fi
done

contains_tag() {
  local version="$1"
  git rev-parse -q --verify "refs/tags/${version}" >/dev/null 2>&1
}

previous_tag_for() {
  local version="$1"
  local previous=""
  for tag in "${TAGS_ASC[@]}"; do
    if [[ "$tag" == "$version" ]]; then
      echo "$previous"
      return 0
    fi
    previous="$tag"
  done
  echo ""
}

latest_tag() {
  if [[ "${#TAGS_DESC[@]}" -gt 0 ]]; then
    echo "${TAGS_DESC[0]}"
    return 0
  fi
  echo ""
}

range_for_version() {
  local version="$1"
  if contains_tag "$version"; then
    local prev
    prev="$(previous_tag_for "$version")"
    if [[ -n "$prev" ]]; then
      echo "${prev}..${version}"
    else
      echo "${version}"
    fi
    return 0
  fi

  local latest
  latest="$(latest_tag)"
  if [[ -n "$latest" ]]; then
    echo "${latest}..HEAD"
  else
    echo "HEAD"
  fi
}

date_for_version() {
  local version="$1"
  if contains_tag "$version"; then
    git log -1 --date=short --pretty=format:%ad "$version"
  else
    echo "$TODAY_UTC"
  fi
}

normalize_feature_subjects() {
  sed -E 's/^feat(\([^)]+\))?:[[:space:]]*//'
}

filter_noise() {
  grep -Ev '^(docs: update DMG link in README \[skip ci\]|docs: update releases log \[skip ci\])$' || true
}

{
  echo "# Releases"
  echo
  echo "Auto-generated release notes by CI on each update of \`main\`."
  echo

  for version in "${VERSIONS_DESC[@]}"; do
    release_date="$(date_for_version "$version")"
    range="$(range_for_version "$version")"

    subjects="$(git log --no-merges --pretty=format:%s "$range" | filter_noise)"
    features="$(printf '%s\n' "$subjects" | grep -E '^feat(\([^)]+\))?: ' | normalize_feature_subjects || true)"

    echo "## ${version} (${release_date})"
    echo
    echo "### Added"
    if [[ -n "$features" ]]; then
      while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        echo "- ${line}"
      done <<< "$features"
    else
      echo "- No feature commit detected for this version."
    fi
    echo
  done
} > "$RELEASES_FILE"

echo "Updated ${RELEASES_FILE}"
