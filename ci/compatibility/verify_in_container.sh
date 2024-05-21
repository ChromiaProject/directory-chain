#!/usr/bin/env sh

set -e

script_dir=$(dirname -- "$0")
project_dir=$script_dir/../../

if ! type bash > /dev/null; then

  echo "Installing dependencies"
  apk add bash curl jq
fi

cd "$project_dir"
./ci/compatibility/verify.sh
