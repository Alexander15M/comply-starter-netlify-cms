#!/bin/bash

# Install comply with Go
go get -v github.com/strongdm/comply

# Adding the Go binary folder to the current path
export PATH="$PATH:$GOPATH/bin"

# Netlify Xenial images don't have a texlive install, so we need to install it on first build.
# We're putting it in the `/opt/build/cache` folder, which is kept between builds
# The following folder is mentioned in netlify-texlive.profile
TEXLIVEDIR="/opt/build/cache/texlive"
TEXLIVEBINDIR="$TEXLIVEDIR/bin/x86_64-linux"

# Let's test that a pdflatex executable is present:
if [ ! -f "$TEXLIVEBINDIR/pdflatex" ]; then
  wget -q http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
  mkdir -p texlive-installer "$TEXLIVEDIR"
  tar -xf install-tl-unx.tar.gz -C ./texlive-installer --strip 1
  ./texlive-installer/install-tl --profile ./netlify-texlive.profile
fi

export PATH="$PATH:$TEXLIVEDIR/bin/x86_64-linux"

# Try to build a "comply.yml" by substituting ENV variable set on netlify (e.g. GITHUB_TOKEN)
envsubst < comply.dist.yml > comply.yml

# All dependencies are installed (from the second build, everything will be loaded from the cache)
# Let's build the documents now!
./run-comply.sh