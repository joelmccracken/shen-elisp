#!/usr/bin/env bash

VERSION=$1

curl -LO https://github.com/Shen-Language/shen-sources/releases/download/shen-${VERSION}/ShenOSKernel-${VERSION}.zip
unzip ShenOSKernel-${VERSION}.zip
cd ShenOSKernel-${VERSION}/klambda/
cp *.kl ../../KLambda/
