#!/bin/bash

set -euo pipefail

GO_VERSION="1.12.4"

if [ $CF_STACK == "cflinuxfs2" ]; then
    GO_SHA256="1a6d80b16a845f6a9692857a5978c0d69a89b58af4d50f66209435beafb07b5b"
elif [ $CF_STACK == "cflinuxfs3" ]; then
    GO_SHA256="e68279204493307782c51105c3dd5254ab066d0b5d9aafa3ce3a2878ebbef53f"
elif [ $CF_STACK == "sle15" ]; then
    GO_SHA256="639d9c3dc546735ba840c9d54c9fefe7bdd0902f990c5368cb161918609db643"
elif [ $CF_STACK == "sle12" ]; then
    GO_SHA256="c24ca643082b482ee1f92a0bca8e4a5582d22f790e027b4ac7dce5b69b617cee"
else
  echo "       **ERROR** Unsupported stack"
  echo "                 See https://docs.cloudfoundry.org/devguide/deploy-apps/stacks.html for more info"
  exit 1
fi

export GoInstallDir="/tmp/go$GO_VERSION"
mkdir -p $GoInstallDir

if [ ! -f $GoInstallDir/go/bin/go ]; then
  if [[ "$CF_STACK" =~ cflinuxfs[23] ]]; then
    URL=https://buildpacks.cloudfoundry.org/dependencies/go/go${GO_VERSION}.linux-amd64-${CF_STACK}-${GO_SHA256:0:8}.tar.gz
  elif [[ "$CF_STACK" == "sle15" || "$CF_STACK" == "sle12" ]]; then
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
