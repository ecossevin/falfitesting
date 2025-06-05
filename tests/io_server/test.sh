#!/bin/bash

set -e
set -x

LFITOOLS=$1
p=$2

cd $p

export DR_HOOK_NOT_MPI=1

ulimit -s unlimited

export LFITOOLS=$1

\rm -rf test/

cp -r t0031 test

cd test

for f in lfi_ io_poll
do
  cp ../../../share/$f .
  chmod +x $f
done

./lfi_

export PATH=$PWD:$PATH

io_poll --prefix ICMSH   > list.ICMSH
io_poll --prefix GRIBPF  > list.GRIBPF

diff list.ICMSH  ref/list.ICMSH
diff list.GRIBPF ref/list.GRIBPF

for f in $(cat list.ICMSH)
do
  $LFITOOLS lfidiff --lfi-file-1 $f --lfi-file-2 ref/$f
done

