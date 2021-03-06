#!/bin/bash
set -e

if [ -z "$1" ]; then
  echo "Usage: $0 container/image:latest /optional/output/dir"
else
  IMAGETAG="$1"
fi
OUTPUTDIR="$PWD"
if [ -n "$2" ]; then
  OUTPUTDIR="$2"
fi

which curl >/dev/null || (echo ERROR curl not found; exit 1)

if ! which download-frozen-image >/dev/null; then
  curl --silent -o /usr/local/bin/download-frozen-image \
      https://raw.githubusercontent.com/moby/moby/master/contrib/download-frozen-image-v2.sh
  chmod +x /usr/local/bin/download-frozen-image
  if ! which go >/dev/null; then
    if [[ "$USER" == "root" ]] && [ -f /etc/debian_version ]; then
      apt install -y golang
    else
      echo "Please install golang first (apt install golang)"
      exit 1
    fi
  fi
  if ! which jq >/dev/null; then
    if [[ "$USER" == "root" ]] && [ -f /etc/debian_version ]; then
      apt install -y jq
    else
      echo "Please install jq first (apt install jq)"
      exit 1
    fi
  fi
fi

rm -rf /tmp/frozen-image 2> /dev/null || true
mkdir -p /tmp/frozen-image
download-frozen-image /tmp/frozen-image "$IMAGETAG"

cd /tmp/frozen-image
if [[ "`jq '.[0].Layers | length' manifest.json`" != "1" ]]; then
  echo "ERROR image contains multiple layers, not a data container"
  exit 1
fi
mkdir -p first-layer
tar xvf `jq -r '.[0].Layers[0]' manifest.json` -C first-layer
mkdir -p "$OUTPUTDIR"
mv first-layer/* "$OUTPUTDIR/"
cd - >/dev/null

exit 0

