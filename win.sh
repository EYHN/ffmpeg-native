#!/usr/bin/env bash
set -e

DOWNLOADS=$PWD/downloads
TARGETS=$PWD/targets

mkdir -p $DOWNLOADS
mkdir -p $TARGETS

CURL="curl --silent --location --retry 3 --retry-max-time 30"

$CURL 'https://github.com/GyanD/codexffmpeg/releases/download/4.4/ffmpeg-4.4-full_build-shared.zip' -o $DOWNLOADS/ffmpeg-4.4-full_build-shared.zip
unzip $DOWNLOADS/ffmpeg-4.4-full_build-shared.zip -d $DOWNLOADS

mkdir -p $TARGETS/win-x64

FFMPEG_LIB=$DOWNLOADS/ffmpeg-4.4-full_build-shared/bin

cp $FFMPEG_LIB/avcodec-58.dll $TARGETS/win-x64
cp $FFMPEG_LIB/avdevice-58.dll $TARGETS/win-x64
cp $FFMPEG_LIB/avfilter-7.dll $TARGETS/win-x64
cp $FFMPEG_LIB/avformat-58.dll $TARGETS/win-x64
cp $FFMPEG_LIB/avutil-56.dll $TARGETS/win-x64
cp $FFMPEG_LIB/postproc-55.dll $TARGETS/win-x64
cp $FFMPEG_LIB/swresample-3.dll $TARGETS/win-x64
cp $FFMPEG_LIB/swscale-5.dll $TARGETS/win-x64

tar zcf $TARGETS/win-x64.tar.gz -C $TARGETS/win-x64 .
