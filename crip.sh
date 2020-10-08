#!/bin/bash

if [ -z "$2" ]; then
  echo "Usage: $0 [install|remove|create] some-python/data-container:latest"
  exit 1
else
  ACTION="$1"
  shift
  IMAGETAG="$1"
  shift
fi

PYTHONDIR="`python3 -c 'from sys import path;import re;r = re.compile(".*/python3\.\d+");p = list(filter(r.fullmatch,path))[0]; print(p)'`"
echo "$ACTION python package(s) in $PYTHONDIR"


if [[ "$ACTION" == "install" ]] || [[ "$ACTION" == "remove" ]]; then
  if ! which crget >/dev/null; then
    curl --silent -o /usr/local/bin/crget \
        https://raw.githubusercontent.com/svlentink/crip/master/crget.sh
    chmod +x /usr/local/bin/crget
  fi
  TARGET=/tmp/crip-content
  rm -rf $TARGET 2>/dev/null || true
  crget "$IMAGETAG" "$TARGET"
  
  cd "$TARGET"
  # Examples of special_actions are:
  # "mv *.crt /etc/ssl/certs/"
  # "pip3 install -r requirements.txt;rm requirement.txt", for which we created the short hand '-req'
  # Thus these actions are executed on the directory
  # that holds the files that came out of the container image
  for special_action in "$@"; do
    if [[ "$special_action" == '-req' ]] && [[ "$ACTION" == "install" ]]; then
      pip3 install -r requirements.txt
      rm requirement.txt
    else
      $special_action
    fi
  done
  cd -

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
  if [ -z "$1" ]; then
    echo "Usage: $0 create my-python/data-container:latest file1.py somedir another.py module_x"
    exit 1
  fi
  if ! which crput >/dev/null; then
    curl --silent -o /usr/local/bin/crput \
        https://raw.githubusercontent.com/svlentink/crip/master/crput.sh
    chmod +x /usr/local/bin/crput
  fi
  FILES="$@"
  crput $IMAGETAG $FILES
else
  echo "ERROR unknown option $ACTION"
  exit 1
fi

