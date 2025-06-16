#!/bin/bash
# (C) Copyright 2022- ECMWF.
# (C) Copyright 2022- Meteo-France.
#
# This software is licensed under the terms of the Apache Licence Version 2.0
# which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.
# In applying this licence, ECMWF does not waive the privileges and immunities
# granted to it by virtue of its status as an intergovernmental organisation
# nor does it submit to any jurisdiction.

set -e
set -x

LFITOOLS=$1
p=$2
src_dir=$3

cd $p

export DR_HOOK_NOT_MPI=1

ulimit -s unlimited

export LFITOOLS=$1

\rm -rf test/

cp -r t0031 test

cd test

for f in lfi_ io_poll
do
  cp $src_dir/share/$f .
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

