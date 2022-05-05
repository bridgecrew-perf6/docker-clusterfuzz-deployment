#!/bin/bash
cd /clusterfuzz
source "$(${PYTHON} -m pipenv --venv)/bin/activate"
gcloud auth login
$PYTHON butler.py deploy --force --targets appengine --prod --config-dir $CONFIG_DIR