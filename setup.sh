#!/bin/sh

export CFLAGS="-O2 -g"
export CC=gcc
export CAIRO_VERSION=1.12.16
# NOTE: cairo-script stuff has problems with newer fontconfig:
export FONTCONFIG_VERSION=2.8.0
export MAKEOPTS=-j2

# setup build environment

export PREFIX=`pwd`/tmp
export LD_LIBRARY_PATH=$PREFIX/pixman/lib:$PREFIX/cairo/lib
export LD_RUN_PATH=$PREFIX/pixman/lib:$PREFIX/cairo/lib
export PKG_CONFIG_PATH=$PREFIX/pixman/lib/pkgconfig:$PREFIX/cairo/lib/pkgconfig:$PREFIX/fontconfig/lib/pkgconfig

if [ ! -d "$PREFIX" ]; then
    mkdir $PREFIX
fi

# clone repositories

if [ ! -d "fontconfig" ]; then
    git clone git://anongit.freedesktop.org/fontconfig
    pushd fontconfig
    git checkout $FONTCONFIG_VERSION
    popd
fi

if [ ! -d "pixman" ]; then
    git clone git://anongit.freedesktop.org/pixman
fi

if [ ! -d "cairo" ]; then
    git clone git://anongit.freedesktop.org/cairo
    pushd cairo
    git checkout $CAIRO_VERSION
    popd
fi

# configure and build fontconfig, pixman and cairo

if [ ! -f "fontconfig/configure" ]; then
    echo "Configuring fontconfig..."
    pushd fontconfig
    ./autogen.sh --prefix=$PREFIX/fontconfig || exit 1
    popd
fi

if [ ! -d "tmp/fontconfig" ]; then
    echo "Compiling fontconfig..."
    pushd fontconfig
    make $MAKEOPTS install || exit 1
    popd
fi

if [ ! -f "pixman/configure" ]; then
    echo "Configuring pixman..."
    pushd pixman
    ./autogen.sh --prefix=$PREFIX/pixman --disable-gtk || exit 1
    popd
fi

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

if [ ! -f "cairo/configure" ]; then
    echo "Configuring cairo..."
    pushd cairo
    ./autogen.sh --prefix=$PREFIX/cairo || exit 1
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
