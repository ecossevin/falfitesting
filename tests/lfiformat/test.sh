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
mkdir -p test
cd test

$LFITOOLS lfitestformat --nopts 10000 --lfi-file LFITEST
$LFITOOLS lfilist LFITEST > LFITEST.list
diff ../ref/LFITEST.list LFITEST.list
