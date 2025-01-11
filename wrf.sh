#!/bin/bash

# Exit on error
set -e

# Define versions and paths
NETCDF_VERSION=4.9.2
MPICH_VERSION=4.1.1
HDF5_VERSION=1.8.22
ZLIB_VERSION=1.2.7
JASPER_VERSION=1.900.1
LIBPNG_VERSION=1.2.50
NETCDF_FORTRAN_VERSION=4.6.2-rc1
WRF_VERSION=4.6.1
WPS_VERSION=4.6.0
INSTALL_DIR=/home/wrf/sysreq
WRF_DIR=/home/wrf/WRF
WPS_DIR=/home/wrf/WPS

# Create installation directories
mkdir -p $INSTALL_DIR
cd $INSTALL_DIR

# Install dependencies
yum groupinstall -y "Development Tools"
yum install -y epel-release
yum install -y \
    gcc \
    gcc-c++ \
    gcc-gfortran \g
    make \
    m4 \
    git \
    wget \
    perl \
    tcsh \
    libcurl-devel \
    libxml2-devel \
    libpng-devel \
    curl \
    python3 \
    python3-pip \
    autoconf

# Install MPICH
wget -q https://www.mpich.org/static/downloads/${MPICH_VERSION}/mpich-${MPICH_VERSION}.tar.gz
tar -xzf mpich-${MPICH_VERSION}.tar.gz
cd mpich-${MPICH_VERSION}
./configure --prefix=$INSTALL_DIR/mpich4
make -j$(nproc)
make install
cd ..
rm -rf mpich-${MPICH_VERSION}*

# Install HDF5
wget -q https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.8/hdf5-1.8.22/src/hdf5-1.8.22.tar.gz
tar xvf hdf5-1.8.22.tar.gz
cd hdf5-1.8.22
./configure --prefix=$INSTALL_DIR/hdf5 --enable-fortran --enable-fortran2003 --enable-cxx
make -j$(nproc)
make install
cd ..
rm -rf hdf5-1.8.22*

# Install zlib
wget -q http://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/zlib-${ZLIB_VERSION}.tar.gz
tar -xvf zlib-${ZLIB_VERSION}.tar.gz
cd zlib-${ZLIB_VERSION}
./configure --prefix=$INSTALL_DIR/grib2
make -j$(nproc)
make install
cd ..
rm -rf zlib-${ZLIB_VERSION}*

# Install netCDF
wget -q https://github.com/Unidata/netcdf-c/archive/v${NETCDF_VERSION}.tar.gz -O netcdf-c.tar.gz
tar -xvf netcdf-c.tar.gz
cd netcdf-c-${NETCDF_VERSION}
./configure --prefix=$INSTALL_DIR/netcdf --enable-shared --with-hdf5=$INSTALL_DIR/hdf5 --with-zlib=$INSTALL_DIR/grib2
make -j$(nproc)
make install
cd ..
rm -rf netcdf-c.tar.gz netcdf-c-${NETCDF_VERSION}

wget -q https://github.com/Unidata/netcdf-fortran/archive/refs/tags/v${NETCDF_FORTRAN_VERSION}.tar.gz -O netcdf-fortran.tar.gz
tar -xzf netcdf-fortran.tar.gz
cd netcdf-fortran-*
./configure --prefix=$INSTALL_DIR/netcdf CPPFLAGS="-I$INSTALL_DIR/netcdf/include" LDFLAGS="-L$INSTALL_DIR/netcdf/lib"
make -j$(nproc)
make install
cd ..
rm -rf netcdf-fortran*

# Install Jasper
wget -q https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/jasper-${JASPER_VERSION}.tar.gz
tar -xzvf jasper-${JASPER_VERSION}.tar.gz
cd jasper-${JASPER_VERSION}
./configure --prefix=$INSTALL_DIR/grib2
make -j$(nproc)
make install
cd ..
rm -rf jasper-${JASPER_VERSION}*

# Install libpng
wget -q https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/libpng-${LIBPNG_VERSION}.tar.gz
tar -xzvf libpng-${LIBPNG_VERSION}.tar.gz
cd libpng-${LIBPNG_VERSION}
./configure --prefix=$INSTALL_DIR/grib2
make -j$(nproc)
make install
cd ..
rm -rf libpng-${LIBPNG_VERSION}*

# Set environment variables
export PATH=$INSTALL_DIR/mpich4/bin:$PATH
export LD_LIBRARY_PATH=$INSTALL_DIR/hdf5/lib:$LD_LIBRARY_PATH
export NETCDF=$INSTALL_DIR/netcdf
export JASPERLIB=$INSTALL_DIR/grib2/lib
export JASPERINC=$INSTALL_DIR/grib2/include

# Clone and compile WRF
git clone https://github.com/wrf-model/WRF.git $WRF_DIR
cd $WRF_DIR
git checkout v${WRF_VERSION}
printf "34\n1\n" | ./configure
./compile em_real

# Clone and compile WPS
git clone https://github.com/wrf-model/WPS.git $WPS_DIR
cd $WPS_DIR
git checkout v${WPS_VERSION}
printf "3\n" | ./configure
./compile

# Download and configure geogrid data
cd /home/wrf
wget -q https://www2.mmm.ucar.edu/wrf/src/wps_files/geog_high_res_mandatory.tar.gz
tar -xvf geog_high_res_mandatory.tar.gz
rm -rf geog_high_res_mandatory.tar.gz
mv WPS_GEOG geog

# Set permissions
chmod -R 777 $INSTALL_DIR

# Output success message
echo "WRF and WPS installation completed successfully!"

