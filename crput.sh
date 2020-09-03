#!/bin/bash
set -e

if [ -z "$1" ]; then
  echo "Usage: $0 container/image:latest somefile.txt anotherdir etc.md"
else
  IMAGETAG="$1"
  shift;
fi
if [ -n "$1" ]; then
  echo "ERROR nothing provided to add to the container"
  exit 1
fi
ITEMS="$@"

which docker >/dev/null || (echo ERROR docker not found; exit 1)

DOCKERFILE=/tmp/crput.Dockerfile
echo 'FROM scratch AS base' > $DOCKERFILE
for i in $ITEMS;do
  echo "COPY $i /$i" >> $DOCKERFILE
done
echo 'FROM scratch' >> $DOCKERFILE
echo 'COPY --from=base / /' >> $DOCKERFILE

docker build -t "$IMAGETAG" -f $DOCKERFILE .

echo "INFO image has been build, we suggest: docker push"
exit 0

