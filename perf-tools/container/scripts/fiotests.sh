#!/bin/bash

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
OUTPATH=$FIOBASEDIR

# Sequential read/write
IODEPTHVALS="8 32"
BLOCKSIZES="32k 256k 1M"

for bs in $BLOCKSIZES
do
  for iodepth in $IODEPTHVALS
  do
    # Sequential writes/reads with 1Mb block size
    fio --name=fiotest-seqwrite-$BS-iodepth-$iodepth  --output=$OUTPATH/fiotest-seqwrite-$BS-iodepth-$iodepth --filename=$FILEPATH --size=$SIZE --rw=write --bs=$bs --direct=1 --numjobs=$NUMTHREADS --ioengine=libaio --iodepth=$iodepth --group_reporting --runtime=$RUNTIME --startdelay=$STARTDELAY
    fio --name=fiotest-seqread-$BS-iodepth-$iodepth  --output=$OUTPATH/fiotest-seqread-$BS-iodepth-$iodepth --filename=$FILEPATH --size=$SIZE --rw=read --bs=$bs --direct=1 --numjobs=$NUMTHREADS --ioengine=libaio --iodepth=$iodepth --group_reporting --runtime=$RUNTIME --startdelay=$STARTDELAY
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
    fio --name=fiotest-randwrite-$bs-iodepth-$iodepth --output=$OUTPATH/fiotest-randwrite-$bs-iodepth-$iodepth --filename=$FILEPATH --size=16Gb --rw=randwrite --bs=$BS --direct=1 --numjobs=$NUMTHREADS --ioengine=libaio --iodepth=$iodepth --group_reporting --runtime=$RUNTIME --startdelay=$STARTDELAY
    fio --name=fiotest-randread-$bs-iodepth-$iodepth --output=$OUTPATH/fiotest-randread-$bs-iodepth-$iodepth --filename=$FILEPATH --size=16Gb --rw=randread --bs=$BS --direct=1 --numjobs=$NUMTHREADS --ioengine=libaio --iodepth=$iodepth --group_reporting --runtime=$RUNTIME --startdelay=$STARTDELAY
  done
done
