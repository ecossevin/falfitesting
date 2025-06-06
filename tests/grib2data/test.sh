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

f_name=$(echo "$f" | sed 's/^[^/]*\///; s/\//_/g')

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

\rm -f zero.$f_name.grib pack.$f_name.grib

$LFITOOLS extractgrib --fa-file $f  --grib-file zero.$f_name.grib --only $(file2list test/$f.diff)
$LFITOOLS extractgrib --fa-file "test/$f" --grib-file pack.$f_name.grib --only "file://test/$f.diff"

ls -l zero.$f_name.grib pack.$f_name.grib

if [ -s zero.grib.$f ]
then

$grib_api_prefix/bin/grib_dump -O zero.$f_name.grib > zero.$f_name.txt
$grib_api_prefix/bin/grib_dump -O pack.$f_name.grib > pack.$f_name.txt

\rm -f zero.grib.$f pack.grib.$f

perl -i -ne ' print unless (m/^\s*\**\s+FILE:/o) ' zero.$f_name.txt pack.$f_name.txt

ls -l zero.$f_name.txt pack.$f_name.txt

set +e
diff zero.$f_name.txt pack.$f_name.txt
set -e

#\mv -f "test/$f" $f

fi
