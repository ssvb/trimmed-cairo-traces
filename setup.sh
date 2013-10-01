#!/bin/sh

export CFLAGS="-O2 -g"
export CC=gcc
export CAIRO_VERSION=1.12.16
export MAKEOPTS=-j2

# setup build environment

export PREFIX=`pwd`/tmp
export LD_LIBRARY_PATH=$PREFIX/pixman/lib:$PREFIX/cairo/lib
export LD_RUN_PATH=$PREFIX/pixman/lib:$PREFIX/cairo/lib
export PKG_CONFIG_PATH=$PREFIX/pixman/lib/pkgconfig:$PREFIX/cairo/lib/pkgconfig

if [ ! -d "$PREFIX" ]; then
    mkdir $PREFIX
fi

# clone repositories

if [ ! -d "pixman" ]; then
    git clone git://anongit.freedesktop.org/pixman
fi

if [ ! -d "cairo" ]; then
    git clone git://anongit.freedesktop.org/cairo
    pushd cairo
    git checkout $CAIRO_VERSION
    popd
fi

# first time configure for pixman and cairo

if [ ! -f "pixman/configure" ]; then
    pushd pixman
    ./autogen.sh --prefix=$PREFIX/pixman --disable-gtk || exit 1
    popd
fi

if [ ! -f "cairo/configure" ]; then
    pushd cairo
    ./autogen.sh --prefix=$PREFIX/cairo || exit 1
    popd
fi

# first time compile and install for pixman and cairo

if [ ! -d "tmp/pixman" ]; then
    echo "Compiling pixman..."
    pushd pixman
    make $MAKEOPTS install || exit 1
    # make symlinks from pixman directory to make further installations unnecessary
    rm $PREFIX/pixman/lib/libpixman-1.so
    rm $PREFIX/pixman/lib/libpixman-1.so.0
    ln -s ../../../pixman/pixman/.libs/libpixman-1.so $PREFIX/pixman/lib/libpixman-1.so
    ln -s ../../../pixman/pixman/.libs/libpixman-1.so.0 $PREFIX/pixman/lib/libpixman-1.so.0
    popd
fi

if [ ! -d "tmp/cairo" ]; then
    echo "Compiling cairo..."
    pushd cairo
    make $MAKEOPTS install || exit 1
    popd

    # bind traces
    echo "Binding traces..."
    make clean
    make || exit 1
fi

echo
echo "Now you can do all the pixman hacking in 'pixman' directory"
echo "and run benchmarks using 'bench.sh script. The pixman shared"
echo "libraries used for the benchmark will be picked from"
echo "'pixman/pixman/.libs' directory."
