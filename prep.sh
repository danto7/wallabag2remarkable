#!/bin/bash

container_tag="wallabag2remarkable"

function download_rmapi() {
  version="0.0.22.1"
  url="https://github.com/juruen/rmapi/releases/download/v$version/rmapi-linuxx86-64.tar.gz"
  checksum="e98999afb4c90c0352bf8c7f05b32013b724d249374bf42d551b1c7dbe657b15"

  echo "> Downloading rmapi in version $version"
  tmp="$(mktemp)"

  curl -sL --output "$tmp" "$url"
  sum="$(sha256sum "$tmp" | cut -d' ' -f1)"

  if [[ "$sum" != "$checksum" ]]; then
    echo "checksums do not match $sum || $checksum"
    exit 1
  fi

  tar -xzf "$tmp" -C "$PWD"

  rm "$tmp"
}

if [[ ! -f ./rmapi ]];then
  download_rmapi
else
  echo "> skipping rmapi download"
fi

