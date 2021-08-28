#!/usr/bin/env bash
set -e

./build-ffmpeg.sh --build

TARGETS=$PWD/targets

mkdir -p $TARGETS

mkdir -p $TARGETS/osx-x64

FFMPEG_LIB=$PWD/workspace/lib

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