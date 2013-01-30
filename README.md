A trimmed varint of cairo traces for cairo-perf-trace
=====================================================

Introduction
------------

This is the repository with a set of traces for [cairo-perf-trace](http://cworth.org/intel/performance_measurement/)
tool. Compared to the original [cairo-traces](http://cgit.freedesktop.org/cairo-traces)
repository, these have been trimmed in order to make the time needed to run
the benchmark reasonable even on very slow embedded systems
(including, but not limited to [Raspberry Pi](http://en.wikipedia.org/wiki/Raspberry_Pi)).

In a nutshell, cairo-perf-trace is probably the most relevant
benchmark for evaluating the performance of [XRender extension](http://en.wikipedia.org/wiki/X_Rendering_Extension)
(the thing, which provides 2D acceleration) implemented by
various Xorg drivers in Linux systems. The cairo library is
installed on practically every desktop linux system and is
commonly used either directly or indirectly (for example via GTK+)
for doing 2D graphics. The *.trace files used as the input for
cairo-perf-trace benchmark are simply the traces of recorded
activity of real applications. It is even possible to use
cairo-trace tool, which is already packaged in many Linux
distros ([cairo-perf-utils](http://packages.ubuntu.com/search?keywords=cairo-perf-utils&searchon=names)
in debian/ubuntu) to record your own traces of the
application you care about.


Setup
-----

Two convenience scripts are included. First after cloning the
repository, you can run "setup.sh" script, which will attempt
to fetch the git sources of the cairo library and also pixman
(the only hard dependency, which provides software rendering
backend). Then the sources are configured, compiled and
installed into a local "tmp" directory.

Be warned that the included scripts are neither user-friendly
nor fool-proof at the moment! Though the most common problem
is expected to be just related to missing build dependencies.
In debian/ubuntu this can be resolved by running:

    sudo apt-get build-dep cairo
    sudo apt-get install git

Use
---

If the setup was successful, then it is possible to run the
benchmark itself. Just run "bench.sh" and it will show human
readable results (time, standard deviation, ...) as the test
proceeds. And also results-raw.txt will be created and contain
"raw", results, which can be processed by **cairo-perf-diff-files**
(a text summary of the difference between two runs) or
**cairo-perf-chart** (a nice graphical chart) tools.
