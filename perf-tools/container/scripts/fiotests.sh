#!/bin/bash

if [ $# -lt 0 ]
then
  TIMESTAMP=$(date "+%Y-%m-%d--%H-%M")
else
  TIMESTAMP=$1
fi

[[ -n ${FIOBASEDIR} && ! -w ${FIOBASEDIR} ]] && echo "Please set environment variable 'FIOBASEDIR' to a writable target directory" && exit 1;
[[ -n ${FIOOUTDIR} ]] && echo "Please set environment variable 'FIOOUTDIR' to value of output sub-directory (will be created in '$FIOBASEDIR')" && exit 1;


# Test file size
SIZE=16Gb
# NumThreads
NUMTHREADS=8
# Startdelay parameter - wait to start test once testfile is written; potentially allow cache buffers to clear
STARTDELAY=60
# Runtime of the test
RUNTIME=60

# Path to test file
FILEPATH=$FIOBASEDIR/testfile_$SIZE
OUTPATH=$FIOBASEDIR/$FIOOUTDIR/$TIMESTAMP

mkdir -p $OUTPATH

# Sequential read/write
IODEPTHVALS="8 32"
BLOCKSIZES="32k 256k 1M"

for bs in $BLOCKSIZES
do
  for iodepth in $IODEPTHVALS
  do
    # Sequential writes/reads with 1Mb block size
    echo "Running fiotest-seqwrite-$bs-iodepth-$iodepth"
    fio --name=fiotest-seqwrite-$bs-iodepth-$iodepth  --output=$OUTPATH/fiotest-seqwrite-$bs-iodepth-$iodepth.txt --filename=$FILEPATH --size=$SIZE --rw=write --bs=$bs --direct=1 --numjobs=$NUMTHREADS --ioengine=libaio --iodepth=$iodepth --group_reporting --runtime=$RUNTIME --startdelay=$STARTDELAY
    echo "Running fiotest-seqread-$bs-iodepth-$iodepth"
    fio --name=fiotest-seqread-$bs-iodepth-$iodepth  --output=$OUTPATH/fiotest-seqread-$bs-iodepth-$iodepth.txt --filename=$FILEPATH --size=$SIZE --rw=read --bs=$bs --direct=1 --numjobs=$NUMTHREADS --ioengine=libaio --iodepth=$iodepth --group_reporting --runtime=$RUNTIME --startdelay=$STARTDELAY
  done
done

# Random read/write
IODEPTHVALS="16 32"
BLOCKSIZES="8k 16k 32k 64k 256k 1M"

for bs in $BLOCKSIZES
do
  for iodepth in $IODEPTHVALS
  do
    # Random writes/reads with $bs block size
    echo "Running fiotest-randwrite-$bs-iodepth-$iodepth"
    fio --name=fiotest-randwrite-$bs-iodepth-$iodepth --output=$OUTPATH/fiotest-randwrite-$bs-iodepth-$iodepth.txt --filename=$FILEPATH --size=16Gb --rw=randwrite --bs=$bs --direct=1 --numjobs=$NUMTHREADS --ioengine=libaio --iodepth=$iodepth --group_reporting --runtime=$RUNTIME --startdelay=$STARTDELAY
    echo "Running fiotest-randread-$bs-iodepth-$iodepth"
    fio --name=fiotest-randread-$bs-iodepth-$iodepth --output=$OUTPATH/fiotest-randread-$bs-iodepth-$iodepth.txt --filename=$FILEPATH --size=16Gb --rw=randread --bs=$bs --direct=1 --numjobs=$NUMTHREADS --ioengine=libaio --iodepth=$iodepth --group_reporting --runtime=$RUNTIME --startdelay=$STARTDELAY
  done
done

# delete the testfile
rm $FILEPATH
