#!/bin/bash
cd /clusterfuzz
source "$(${PYTHON} -m pipenv --venv)/bin/activate"
gcloud auth login
$PYTHON butler.py create_config --oauth-client-secrets-path=$CLIENT_SECRETS_PATH --firebase-api-key=$FIREBASE_API_KEY --project-id=$CLOUD_PROJECT_ID $CONFIG_DIR