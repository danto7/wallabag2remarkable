#!/bin/bash

container_tag="wallabag2remarkable"

function download_rmapi() {
  version="0.0.20"
  url="https://github.com/juruen/rmapi/releases/download/v$version/rmapi-linuxx86-64.tar.gz"
  checksum="2ab275c838eed7254d363e9623f04062d4f45132fc1f00ddfcf7b5458720a958"

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

