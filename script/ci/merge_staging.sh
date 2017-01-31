#!/bin/bash

set -e

echo "--- checking out branch"
git reset --hard
git checkout staging

echo "--- merging master into staging"
git fetch -p origin
git merge origin/master --no-ff -m "Merging master into staging"

echo "--- pushing changes to github"
# this will kick off a build for staging
git push -f origin staging:staging
