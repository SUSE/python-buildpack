#!/bin/bash

set -euo pipefail

GO_VERSION="1.11.5"

if [ $CF_STACK == "cflinuxfs2" ]; then
    GO_SHA256="51cab63f3de5e2f75a9036801712e4d7ae9bf226f0b61abce8d784e698148d3b"
elif [ $CF_STACK == "cflinuxfs3" ]; then
    GO_SHA256="ee770df4e1863ee8e07574cb48e0245b61bec8f118faf6ec3742ea89eb20db28"
elif [ $CF_STACK == "sle15" ]; then
    GO_SHA256="732874fea9c679e4e6239ffd0d04433f7b72aaef3f3636a2684d9e538e2afb5e"
elif [ $CF_STACK == "sle12" ]; then
    GO_SHA256="a369350d61414f7a767972e105cc8c3f8ef8e18664165b564538042d1ea944cf"
elif [ $CF_STACK == "opensuse42" ]; then
    GO_SHA256="34fba3be2b639ea8970dd193dd0823493b6911fc4dba83f46eadd6e365704290"
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
  elif [[ "$CF_STACK" == "sle15" || "$CF_STACK" == "sle12" || "$CF_STACK" == "opensuse42" ]]; then
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
