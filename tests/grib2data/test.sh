# (C) Copyright 2022- ECMWF.
# (C) Copyright 2022- Meteo-France.
#
# This software is licensed under the terms of the Apache Licence Version 2.0
# which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.
# In applying this licence, ECMWF does not waive the privileges and immunities
# granted to it by virtue of its status as an intergovernmental organisation
# nor does it submit to any jurisdiction.

set -e

f=$1
LFITOOLS=$2
p=$3
grib_api_prefix=$4

cd $p

export GRIB_DEFINITION_PATH=$p/extra_grib_defs:$grib_api_prefix/share/definitions:$grib_api_prefix/share/eccodes/definitions
export GRIB_SAMPLES_PATH=$grib_api_prefix/ifs_samples/grib1:$grib_api_prefix/share/eccodes/ifs_samples/grib1
export PATH=$grib_api_prefix/bin:$PATH

function file2list ()
{
  file=$1
  perl -e '
my @list = <>;
chomp for (@list);
print "@list"
' < $file
}



\rm -f "test/$f"
d=$(dirname "test/$f")
mkdir -p $d

$LFITOOLS fatestgrib2data --fa-file-1 $f  --fa-file-2 "test/$f"  
$LFITOOLS lfidiff --lfi-file-1 $f  --lfi-file-2 "test/$f" --out "test/$f.diff"

\rm -f zero.grib pack.grib

$LFITOOLS extractgrib --fa-file $f  --grib-file zero.grib --only $(file2list test/$f.diff)
$LFITOOLS extractgrib --fa-file "test/$f" --grib-file pack.grib --only "file://test/$f.diff"

ls -l zero.grib pack.grib

if [ -s zero.grib ]
then

$grib_api_prefix/bin/grib_dump -O zero.grib > zero.txt
$grib_api_prefix/bin/grib_dump -O pack.grib > pack.txt

\rm -f zero.grib pack.grib

perl -i -ne ' print unless (m/^\s*\**\s+FILE:/o) ' zero.txt pack.txt

ls -l zero.txt pack.txt

set +e
diff zero.txt pack.txt
set -e

#\mv -f "test/$f" $f

fi
