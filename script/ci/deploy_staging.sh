#!/bin/bash

set -e

echo "--- deploying to staging"

echo `heroku config:get STAGING_ID_CERT_PEM --app cyclelifehq-staging` > cleardb_id-cert-staging.pem
echo `heroku config:get STAGING_ID_KEY_PEM --app cyclelifehq-staging` > cleardb_id-key-staging.pem
echo `heroku config:get STAGING_CA_PEM --app cyclelifehq-staging` > cleardb-ca-staging.pem

git push -f heroku-staging "$BUILDKITE_COMMIT":master
