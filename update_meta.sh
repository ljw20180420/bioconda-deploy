#!/bin/bash

update_meta() {
    local url=$1
    local pkg=$(sed -r 's|https://github.com/ljw20180420/(.*)/archive/refs/tags/.*\.tar\.gz|\1|' <<<${url})
    local tarball=${url##*/}
    local version=${tarball%.tar.gz}
    local version=${version#v}
    local escaped_version=$(sed -r 's/\./\\\./g' <<<${version})
    local url_with_dynamic_version=$(sed -r 's/'${escaped_version}'/{{ version }}/' <<<${url})
    if ! [ -f "v${version}.tar.gz" ]
    then
        wget $url
    fi
    local sha256=$(sha256sum ${tarball} | cut -d' ' -f1)

    sed -r -i \
        -e '/^\{% set version = ".*" %\}$/ s/"(.*)"/"'"${version}"'"/' \
        -e '/^  url: / s|^(  url: )(.*)$|\1'"${url_with_dynamic_version}"'|' \
        -e '/^  sha256: / s|^(  sha256: )(.*)$|\1'"${sha256}"'|' \
        "recipes/${pkg}/meta.yaml"
}
