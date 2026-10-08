#!/usr/bin/env bash

set -e

fetch_and_extract() {
    rm -rf version source_release
    curl -so version "https://raw.githubusercontent.com/snazzyatoms/sentinel-browser/main/version"
    curl -so source_release "https://raw.githubusercontent.com/snazzyatoms/sentinel-browser/main/release"

    rm -f "sentinel-$(cat version)-$(cat source_release).source.tar.gz"
    curl -so "sentinel-$(cat version)-$(cat source_release).source.tar.gz" "https://github.com/snazzyatoms/sentinel-browser/releases/download/v$(cat version)-$(cat source_release)/sentinel-$(cat version)-$(cat source_release).source.tar.gz"

    rm -rf sentinel-$(cat version)
    tar xf sentinel-$(cat version)-$(cat source_release).source.tar.gz

    # here would be a great spot to insert system dependent stuff like mozconfig/patches.
}

build() {
    cd sentinel-$(cat version)
      ./mach build
      ./mach package
    cd ..
}

artifacts() {
    # ... Here we do system dependent stuff like builing rpm's, setup.exe or other formats we distribute in
}

build_all() {
    fetch_and_extract
    build
    artifacts
}

build_all
