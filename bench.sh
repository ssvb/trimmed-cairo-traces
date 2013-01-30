#!/bin/sh

if [ x$CAIRO_TEST_TARGET == "x" ]
then
    echo "CAIRO_TEST_TARGET enviromnent variable is not set, the possible options are:"
    echo
    echo "   export CAIRO_TEST_TARGET=image   (software rendering, 32 bits per pixel)"
    echo "   export CAIRO_TEST_TARGET=image16 (software rendering, 16 bits per pixel)"
    echo "   export CAIRO_TEST_TARGET=xlib    (use the 2D accelerated driver from X server)"
    echo
    echo "In the case if you are running in a ssh session and still want to benchmark"
    echo "the 2D acceleration provided by the X server, sometimes you may need to also:"
    echo
    echo "   export DISPLAY=:0"
    echo
    echo "Please set the needed environment variables as explained above and try again."
    exit 1
fi

export PREFIX=`pwd`/tmp
export LD_LIBRARY_PATH=$PREFIX/pixman/lib:$PREFIX/cairo/lib

if [ ! -d "$PREFIX" ]; then
    echo "Please run the setup.sh script first"
    exit 1
fi

# run the benchmarks

cairo/perf/.libs/cairo-perf-trace benchmark -r -v -i8 > results-raw.txt
