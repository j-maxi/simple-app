#!/usr/bin/env bash
# set -o errexit
# set -o nounset
 

DESIGNPATTERN_REPO="designpatterns"

# Resolve app revision
REVISION=`git log -1 --pretty=format:"%H"`

# Resolve design pattern revision
cd ${DESIGNPATTERN_REPO}
DESIGNPATTERN_REVISION=`git log -1 --pretty=format:"%H"`

>&2 echo "Generating Tekton Pipeline with application revision=${REVISION} and design pattern revision=${DESIGNPATTERN_REVISION}..."
docker run --rm -it -v $PWD/..:/app -v $PWD:/designpatterns -w /designpatterns cuelang/cue:0.2.1 \
  export /app/build/app.cue -e tektonPipeline \
  -t revision=${REVISION} \
  -t designpatternRevision=${DESIGNPATTERN_REVISION} \
  --out=yaml
