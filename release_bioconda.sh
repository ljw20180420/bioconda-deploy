#!/bin/bash

source "update_meta.sh"

url=$1
pkg=$(sed -r 's|https://github.com/ljw20180420/(.*)/archive/refs/tags/.*\.tar\.gz|\1|' <<<${url})

git checkout master
# Delete local branch
git branch -D "update_${pkg}"
# Delete branch in your fork via the remote named "origin"
git push origin -d "update_${pkg}"

# exit on error
set -e

# Make sure our master is up to date with Bioconda
git pull upstream master
git push origin master

# Create and checkout a new branch
git checkout -b "update_${pkg}"

update_meta ${url}

git commit -am "Update ${pkg}"

git push --set-upstream origin "update_${pkg}"

conda build "recipes/${pkg}"

gh pr create --repo bioconda/bioconda-recipes --fill --template PULL_REQUEST_TEMPLATE.md
