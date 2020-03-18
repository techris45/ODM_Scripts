#!/bin/bash

if [[ $2 =~ ^[0-9]+$ ]] ; then
    processes=$2
else
    processes=$(nproc)
fi

install() {
    ## Set up library paths
    export PYTHONPATH=$RUNPATH/SuperBuild/install/lib/python2.7/dist-packages:$RUNPATH/SuperBuild/src/opensfm:$PYTHONPATH
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$RUNPATH/SuperBuild/install/lib

    ## Before installing
    echo "Updating the system"
    #add-apt-repository -y ppa:ubuntugis/ubuntugis-unstable
    apt update

    echo "Installing Required Requisites"
    apt install -y -qq build-essential \
                         git \
                         cmake \
                         python3-pip \
                         libgdal-dev \
                         gdal-bin \
                         libgeotiff-dev \
                         pkg-config \
                         libjsoncpp-dev \
                         python3-gdal \
                         grass-core \
                         libssl-dev \
                         liblas-bin \
                         swig \
                         python3-wheel \
                         libboost-log-dev
                         libusb-1.0-0-dev

    echo "Getting CMake 3.1 for MVS-Texturing"
    apt install -y software-properties-common python3-software-properties
    #add-apt-repository -y ppa:george-edison55/cmake-3.x
    apt update -y
    apt install -y --only-upgrade cmake

    echo "Installing OpenCV Dependencies"
    apt install -y -qq libgtk-3-dev \
                         libavcodec-dev \
                         libavformat-dev \
                         libswscale-dev \
                         python3-dev \
                         libtbb2 \
                         libtbb-dev \
                         libjpeg-dev \
                         libpng-dev \
                         libtiff-dev \
                         libjasper-dev \
                         libflann-dev \
                         libproj-dev \
                         libxext-dev \
                         liblapack-dev \
                         libeigen3-dev \
                         libvtk6-dev
                         libvtk6-qt-dev
                         libvtk7-dev
                         libvtk7-qt-dev

    echo "Removing libdc1394-22-dev due to python opencv issue"
    apt remove libdc1394-22-dev

    echo "Installing OpenSfM Dependencies"
    apt install -y -qq libgoogle-glog-dev \
                         libsuitesparse-dev \
                         libboost-filesystem-dev \
                         libboost-iostreams-dev \
                         libboost-regex-dev \
                         libboost-python-dev \
                         libboost-date-time-dev \
                         libboost-thread-dev

    pip install -r "${RUNPATH}/requirements.txt"

    # Fix:  /usr/local/lib/python2.7/dist-packages/requests/__init__.py:83: RequestsDependencyWarning: Old version of cryptography ([1, 2, 3]) may cause slowdown.
    pip install --upgrade cryptography
    python -m easy_install --upgrade pyOpenSSL

    echo "Compiling SuperBuild"
    cd ${RUNPATH}/SuperBuild
    mkdir -p build && cd build
    cmake .. && make -j$processes

    echo "Compiling build"
    cd ${RUNPATH}
    mkdir -p build && cd build
    cmake .. && make -j$processes

    echo "Configuration Finished"
}

uninstall() {
    echo "Removing SuperBuild and build directories"
    cd ${RUNPATH}/SuperBuild
    rm -rfv build src download install
    cd ../
    rm -rfv build
}

reinstall() {
    echo "Reinstalling ODM modules"
    uninstall
    install
}

usage() {
    echo "Usage:"
    echo "bash configure.sh <install|update|uninstall|help> [nproc]"
    echo "Subcommands:"
    echo "  install"
    echo "    Installs all dependencies and modules for running OpenDroneMap"
    echo "  reinstall"
    echo "    Removes SuperBuild and build modules, then re-installs them. Note this does not update OpenDroneMap to the latest version. "
    echo "  uninstall"
    echo "    Removes SuperBuild and build modules. Does not uninstall dependencies"
    echo "  help"
    echo "    Displays this message"
    echo "[nproc] is an optional argument that can set the number of processes for the make -j tag. By default it uses $(nproc)"
}

if [[ $1 =~ ^(install|reinstall|uninstall|usage)$ ]]; then
    RUNPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    "$1"
else
    echo "Invalid instructions." >&2
    usage
    exit 1
fi
