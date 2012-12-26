#!/bin/sh

export CAIRO_TEST_TARGET=image

export PREFIX=`pwd`/tmp
export LD_LIBRARY_PATH=$PREFIX/pixman/lib:$PREFIX/cairo/lib

if [ ! -d "$PREFIX" ]; then
    echo "Please run the setup.sh script first"
    exit 1
fi

# run the benchmarks

cairo/perf/.libs/cairo-perf-trace benchmark
