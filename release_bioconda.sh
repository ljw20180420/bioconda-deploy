#!/bin/bash

update_meta() {
    local url=$1
    local tarball=${url##*/}
    local version=${tarball%.tar.gz}
    local version=${version#v}
    local escaped_version=$(sed -r 's/\./\\\./g' <<<${version})
    local url_with_dynamic_version=$(sed -r 's/'${escaped_version}'/{{ version }}/' <<<${url})
    echo ${escaped_version}
    echo ${url_with_dynamic_version}
    wget $url
    local sha256=$(sha256sum ${tarball} | cut -d' ' -f1)

    sed -r -i \
        -e '/^\{% set version = ".*" %\}$/ s/"(.*)"/"'"${version}"'"/' \
        -e '/^  url: / s|(https://github.com/ljw20180420/rearr/archive/refs/tags/.*\.tar\.gz)$|'"${url_with_dynamic_version}"'|' \
        -e '/^  sha256: / s|^(  sha256: )(.*)$|\1'${sha256}'|' \
        recipes/rearr/meta.yaml
}

git checkout master
# Delete local branch
git branch -D update_rearr
# Delete branch in your fork via the remote named "origin"
git push origin -d update_rearr

# exit on error
set -e

# Make sure our master is up to date with Bioconda
git pull upstream master
git push origin master

# Create and checkout a new branch for rearr
git checkout -b update_rearr

update_meta $1

git commit -am "Update rearr"

git push --set-upstream origin update_rearr

conda build recipes/rearr

gh pr create --repo bioconda/bioconda-recipes --fill --template PULL_REQUEST_TEMPLATE.md
