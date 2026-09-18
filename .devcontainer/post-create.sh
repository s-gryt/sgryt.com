#!/bin/sh

set -eu

if [ ! -f .env ]; then
  echo "Missing .env. Copy .env.example to .env and set the required values." >&2
  exit 1
fi

. ./.env

: "${GIT_USER_EMAIL:?GIT_USER_EMAIL must be set in .env}"
: "${GIT_USER_NAME:?GIT_USER_NAME must be set in .env}"

git config --local user.email "$GIT_USER_EMAIL"
git config --local user.name "$GIT_USER_NAME"
unset GIT_USER_EMAIL GIT_USER_NAME

bundle install
npm ci
