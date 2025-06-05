#!/bin/bash

set -e
set -x

LFITOOLS=$1
p=$2

cd $p

export DR_HOOK_NOT_MPI=1

ulimit -s unlimited

\rm -rf test/

cp -r t0031 test

cd test

for f in lfi_ 
do
  cp ../../../../../../share/$f .
  chmod +x $f
done

./lfi_

export PATH=$PWD:$PATH
export LFITOOLS

lfi_

lfi_merge io_serv.*.d/ICMSH0000+0006:00.* ICMSH0000+0006:00

$LFITOOLS lfilist ICMSH0000+0006:00 > ICMSH0000+0006:00.list

diff ICMSH0000+0006:00.list ref/ICMSH0000+0006:00.list

lfi_pack ICMSH0000+0006:00 > ICMSH0000+0006:00.pack

for intent in "in" "inout"
do
lfi_copy -intent=$intent ICMSH0000+0006:00 ICMSH0000+0006:00.copy.$intent
done

for f in ICMSH0000+0006:00 ICMSH0000+0006:00.pack ICMSH0000+0006:00.copy.in ICMSH0000+0006:00.copy.inout
do
$LFITOOLS lfidiff --lfi-file-1 $f --lfi-file-2 ref/ICMSH0000+0006:00.pack
done


for d in ICMSH0000+0006:00.d ICMSH0000+0006:00.copy.in.d ICMSH0000+0006:00.copy.inout.d
do
  if [ ! -d "$d" ]
  then
    echo "Missing directory $d"
    exit 1
  fi
done

for f in ICMSH0000+0006:00.pack ICMSH0000+0006:00.copy.inout
do
if [ $(stat -c %a "$f") != "644" ]
then
  echo "File $f has wrong permissions"
  exit 1
fi
done

for f in ICMSH0000+0006:00 ICMSH0000+0006:00.copy.in
do
if [ $(stat -c %a "$f") != "444" ]
then
  echo "File $f has wrong permissions"
  exit 1
fi
done

