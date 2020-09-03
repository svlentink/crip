#!/bin/bash

if [ -z "$2"]; then
  echo "Usage: $0 [install|remove|create] some-python/data-container:latest"
  exit 1
else
  ACTION="$1"
  IMAGETAG="$2"
fi

PYTHONDIR="`python3 -c 'from sys import path;import re;r = re.compile(".*/python3\.\d+");p = list(filter(r.fullmatch,path))[0]; print(p)'`"
echo "$ACTION python package(s) in $PYTHONDIR"

TARGET=/tmp/crip-content
rm -rf $TARGET 2>/dev/null || true

if [[ "$ACTION" == "install" ]] || [[ "$ACTION" == "remove" ]]; then
  if ! which crget; then
    curl -o /usr/local/bin/crget fixme-some-url
  fi
  crget "$IMAGETAG" "$TARGET"
  if [[ "$ACTION" == "install" ]]; then
    mv $TARGET/* $PYTHONDIR/
  fi
  if [[ "$ACTION" == "remove" ]]; then
    cd $TARGET
    for f in `find`; do
      rm -rf $PYTHONDIR/$f 2>/dev/null || true
    done
  fi
  rm -rf $TARGET
  exit 0
fi
if [[ "$ACTION" == "create" ]]; then
  if [ -z "$3" ]; then
    echo "Usage: $0 create my-python/data-container:latest file1.py somedir another.py module_x"
    exit 1
  fi
  echo "WARN not implemented yet"
else
  echo "ERROR unknown option $ACTION"
  exit 1
fi

