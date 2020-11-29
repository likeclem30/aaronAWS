#!/bin/bash

set -o errexit -o nounset -o pipefail

branchName="master"

git checkout -b ${TAG_NAME}

git add "${BERKSFILE_PATH}.lock"
git diff --quiet --exit-code --cached || git commit -m "Build ${TAG_NAME}"
git tag -f ${TAG_NAME}
git checkout ${branchName}
git pull origin ${branchName}
git merge ${TAG_NAME} --strategy-option theirs --no-edit

git branch -D ${TAG_NAME}
git push -f origin ${branchName} --tags

