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
