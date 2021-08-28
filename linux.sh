#!/usr/bin/env bash
set -e

sudo apt-get -y install patchelf

DOWNLOADS=$PWD/downloads
TARGETS=$PWD/targets

mkdir -p $DOWNLOADS
mkdir -p $TARGETS

CURL="curl --silent --location --retry 3 --retry-max-time 30"

$CURL 'https://github.com/BtbN/FFmpeg-Builds/releases/download/autobuild-2021-08-24-12-22/ffmpeg-n4.4-80-gbf87bdd3f6-linux64-gpl-shared-4.4.tar.xz' | tar Jx -C $DOWNLOADS

mkdir -p $TARGETS/linux-x64

FFMPEG_LIB=$DOWNLOADS/ffmpeg-n4.4-80-gbf87bdd3f6-linux64-gpl-shared-4.4/lib

cp $FFMPEG_LIB/libavcodec.so.58 $TARGETS/linux-x64
cp $FFMPEG_LIB/libavdevice.so.58 $TARGETS/linux-x64
cp $FFMPEG_LIB/libavfilter.so.7 $TARGETS/linux-x64
cp $FFMPEG_LIB/libavformat.so.58 $TARGETS/linux-x64
cp $FFMPEG_LIB/libavutil.so.56 $TARGETS/linux-x64
cp $FFMPEG_LIB/libpostproc.so.55 $TARGETS/linux-x64
cp $FFMPEG_LIB/libswresample.so.3 $TARGETS/linux-x64
cp $FFMPEG_LIB/libswscale.so.5 $TARGETS/linux-x64

chmod 755 $TARGETS/osx-x64/*

for file in $TARGETS/linux-x64/*.so*; do
    patchelf --set-rpath "\$ORIGIN" $file
done

tar zcf $TARGETS/linux-x64.tar.gz -C $TARGETS linux-x64
