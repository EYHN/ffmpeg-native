#!/usr/bin/env bash
set -e

DOWNLOADS=$PWD/downloads
TARGETS=$PWD/targets

mkdir -p $DOWNLOADS
mkdir -p $TARGETS

CURL="curl --silent --location --retry 3 --retry-max-time 30"

$CURL 'https://github.com/BtbN/FFmpeg-Builds/releases/download/autobuild-2021-11-28-12-23/ffmpeg-n4.4.1-2-gcc33e73618-win64-gpl-shared-4.4.zip' -o $DOWNLOADS/ffmpeg-n4.4-80-gbf87bdd3f6-win64-gpl-shared-4.4.zip
unzip $DOWNLOADS/ffmpeg-n4.4.1-2-gcc33e73618-win64-gpl-shared-4.4.zip -d $DOWNLOADS

mkdir -p $TARGETS/win-x64

FFMPEG_LIB=$DOWNLOADS/ffmpeg-n4.4.1-2-gcc33e73618-win64-gpl-shared-4.4/bin

cp $FFMPEG_LIB/avcodec-58.dll $TARGETS/win-x64
cp $FFMPEG_LIB/avdevice-58.dll $TARGETS/win-x64
cp $FFMPEG_LIB/avfilter-7.dll $TARGETS/win-x64
cp $FFMPEG_LIB/avformat-58.dll $TARGETS/win-x64
cp $FFMPEG_LIB/avutil-56.dll $TARGETS/win-x64
cp $FFMPEG_LIB/swresample-3.dll $TARGETS/win-x64
cp $FFMPEG_LIB/swscale-5.dll $TARGETS/win-x64

tar zcf $TARGETS/win-x64.tar.gz -C $TARGETS win-x64
