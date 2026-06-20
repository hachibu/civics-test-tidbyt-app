#!/bin/bash
set -e

if [ ! -d "/tmp/tidbyt-community" ]; then
  echo "Error: /tmp/tidbyt-community not found. Clone the community fork first."
  exit 1
fi

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COMMUNITY_DIR="/tmp/tidbyt-community/apps/civicstest"

echo "Syncing civics_test.star and manifest.yaml to community fork..."
cp "$REPO_DIR/civics_test.star" "$COMMUNITY_DIR/civics_test.star"
cp "$REPO_DIR/manifest.yaml" "$COMMUNITY_DIR/manifest.yaml"

cd "$COMMUNITY_DIR/../.."
git add "apps/civicstest/civics_test.star" "apps/civicstest/manifest.yaml"

# Get the latest commit message from the main repo
COMMIT_MSG=$(cd "$REPO_DIR" && git log -1 --pretty=%B)
git commit -m "$COMMIT_MSG"

git push origin civics-test
echo "✓ Community fork synced and pushed to civics-test branch"
