#!/bin/bash

set -euo pipefail

GO_VERSION="1.11.4"

if [ $CF_STACK == "cflinuxfs2" ]; then
    GO_SHA256="8faf0b1823cf25416aa5ffdac6eef2f105114abe41b31b3d020102ae7661a5ae"
elif [ $CF_STACK == "cflinuxfs3" ]; then
    GO_SHA256="964b0b16d3a0b5ddf6705618537581e6ca7c101617a38ac0da4236685f0aa0ce"
elif [ $CF_STACK == "sle12" ]; then
    GO_SHA256="77f42e41b13f14e779e581df7dfae48c4108d000024f2de7d8ff02cc8ff79af4"
elif [ $CF_STACK == "opensuse42" ]; then
    GO_SHA256="7d5aac5781a8be1cc42d04b6512d585a500e5d5ab134487b0aca5eb6e72dc653"
fi

export GoInstallDir="/tmp/go$GO_VERSION"
mkdir -p $GoInstallDir

if [ ! -f $GoInstallDir/go/bin/go ]; then
  if [[ "$CF_STACK" =~ cflinuxfs[23] ]]; then
    URL=https://buildpacks.cloudfoundry.org/dependencies/go/go${GO_VERSION}.linux-amd64-${CF_STACK}-${GO_SHA256:0:8}.tar.gz
  elif [[ "$CF_STACK" == "sle12" || "$CF_STACK" == "opensuse42" ]]; then
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
