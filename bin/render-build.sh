#!/usr/bin/env bash
set -o errexit

bundle install
SECRET_KEY_BASE_DUMMY=1 bundle exec rails assets:precompile
SECRET_KEY_BASE_DUMMY=1 bundle exec rails assets:clean

# Free plan has no pre-deploy command; prepare DB during build.
./bin/render-release.sh
