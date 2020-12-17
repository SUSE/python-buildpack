#!/bin/bash

set -euo pipefail

GO_VERSION="1.15.5"

if [ $CF_STACK == "cflinuxfs3" ]; then
    GO_SHA256="fd04494f7a2dd478b0d31cb949aae7f154749cae1242581b1574f7e590b3b7e6"
elif [ $CF_STACK == "sle15" ]; then
    GO_SHA256="32eb75a7e8576998a8958b2ce3f3cfda1f1166e2e1959955a9490c458a803f8b"
else
  echo "       **ERROR** Unsupported stack"
  echo "                 See https://docs.cloudfoundry.org/devguide/deploy-apps/stacks.html for more info"
  exit 1
fi

export GoInstallDir="/tmp/go$GO_VERSION"
mkdir -p $GoInstallDir

if [ ! -f $GoInstallDir/go/bin/go ]; then
  if [[ "$CF_STACK" =~ cflinuxfs3 ]]; then
    URL=https://buildpacks.cloudfoundry.org/dependencies/go/go${GO_VERSION}.linux-amd64-${CF_STACK}-${GO_SHA256:0:8}.tar.gz
  elif [[ "$CF_STACK" == "sle15" ]]; then
    URL=https://cf-buildpacks.suse.com/dependencies/go/go-${GO_VERSION}-linux-amd64-${CF_STACK}-${GO_SHA256:0:8}.tgz
  fi

  echo "-----> Download go ${GO_VERSION}"
  curl -s -L --retry 15 --retry-delay 2 $URL -o /tmp/go.tar.gz

  DOWNLOAD_SHA256=$(shasum -a 256 /tmp/go.tar.gz | cut -d ' ' -f 1)

  if [[ $DOWNLOAD_SHA256 != $GO_SHA256 ]]; then
    echo "       **ERROR** SHA256 mismatch: got $DOWNLOAD_SHA256 expected $GO_SHA256"
    exit 1
  fi

  tar xzf /tmp/go.tar.gz -C $GoInstallDir
  rm /tmp/go.tar.gz
fi
if [ ! -f $GoInstallDir/go/bin/go ]; then
  echo "       **ERROR** Could not download go"
  exit 1
fi
