#!/usr/bin/env bash
set -e

DOWNLOADS=$PWD/downloads
TARGETS=$PWD/targets

mkdir -p $DOWNLOADS
mkdir -p $TARGETS

CURL="curl --silent --location --retry 3 --retry-max-time 30"

$CURL 'https://ghcr.io/v2/homebrew/core/ffmpeg/blobs/sha256:9da28933b9f1abc3b1cf92382d1a8ea051c98f9dd0f4ef47e8d37d2aa9a4769a' \
    -H 'Host: ghcr.io' \
    -H 'Authorization: Bearer QQ==' | tar zx -C $DOWNLOADS

mkdir -p $TARGETS/osx-x64

FFMPEG_LIB=$DOWNLOADS/ffmpeg/4.4_2/lib

cp $FFMPEG_LIB/libavcodec.58.dylib $TARGETS/osx-x64
cp $FFMPEG_LIB/libavdevice.58.dylib $TARGETS/osx-x64
cp $FFMPEG_LIB/libavfilter.7.dylib $TARGETS/osx-x64
cp $FFMPEG_LIB/libavformat.58.dylib $TARGETS/osx-x64
cp $FFMPEG_LIB/libavresample.4.dylib $TARGETS/osx-x64
cp $FFMPEG_LIB/libavutil.56.dylib $TARGETS/osx-x64
cp $FFMPEG_LIB/libpostproc.55.dylib $TARGETS/osx-x64
cp $FFMPEG_LIB/libswresample.3.dylib $TARGETS/osx-x64
cp $FFMPEG_LIB/libswscale.5.dylib $TARGETS/osx-x64

chmod 755 $TARGETS/osx-x64/*

for file in $TARGETS/osx-x64/*.dylib; do
    install_name_tool -add_rpath "@loader_path" $file
done

tar zcf $TARGETS/osx-x64.tar.gz -C $TARGETS osx-x64