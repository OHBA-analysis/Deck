#!/bin/bash

HERE=$(dirname "${BASH_SOURCE}")

# clone Armadillo repository
ARMA_NAME=armadillo-code
ARMA_REPO=https://gitlab.com/conradsnicta
ARMA_RELP=inc

ARMA_TARGET=$HERE/$ARMA_RELP
ARMA_FOLDER=$ARMA_TARGET/$ARMA_NAME
ARMA_URL=$ARMA_REPO/${ARMA_NAME}.git

if [ ! -d "$ARMA_FOLDER" ]; then
    git clone "$ARMA_URL" "$ARMA_TARGET"
    (( $? == 0 )) || echo "ERROR: could not clone repo '$ARMA_URL' into folder '$ARMA_FOLDER'"
else
    echo "Found Armadillo in: $ARMA_FOLDER"
    echo "    (if the folder is empty / corrupted, delete it first)"
fi

