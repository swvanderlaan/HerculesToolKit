#!/bin/bash
mkdir -p /hpc/local/$MY_DISTRO/$MY_GROUP/software/hacks/fastlmm-0.2.21
cd /hpc/local/$MY_DISTRO/$MY_GROUP/software/hacks/fastlmm-0.2.21
ln -s /usr/lib64/atlas/libsatlas.so libatlas.so
ln -s /usr/lib64/atlas/libsatlas.so libcblas.so
ln -s /usr/lib64/atlas/libsatlas.so libf77blas.so


mkdir -p /hpc/local/$MY_DISTRO/$MY_GROUP/etc/modulefiles/hacks/fastlmm

cat <<EOF > /hpc/local/$MY_DISTRO/$MY_GROUP/etc/modulefiles/hacks/fastlmm/0.2.21.lua

help(
[[
hacks/fastlmm (version 0.2.21) is a hack to safely use skikit-learn that was compiled using pip and libatlas libraries. -h.d.d.kerstens@umcutrecht.nl
]])

whatis("hacks/fastlmm (version 0.2.21 ) is a hack to safely use skikit-learn compiled using pip and libatlas libraries. -h.d.d.kerstens@umcutrecht.nl")


local version = "0.2.21"
local base = "/hpc/local/$MY_DISTRO/$MY_GROUP/software/hacks/fastlmm-" .. version

--load("python/2.7.10")

--prereq("python/2.7.10")

conflict("hacks/fastlmm")

prepend_path("LIBRARY_PATH", base)
prepend_path("PYTHONPATH", base)

EOF

module load hacks/fastlmm
pip install fastlmm  --no-cache-dir -t /hpc/local/$MY_DISTRO/$MY_GROUP/software/hacks/fastlmm-0.2.21
