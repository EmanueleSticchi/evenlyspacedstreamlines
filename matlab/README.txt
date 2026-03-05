MATLAB wrapper for evenlyspacedstreamlines
==========================================

This folder provides a MATLAB interface for generating evenly spaced streamlines
on triangulated surfaces.

Files
-----
- evenly_spaced_streamlines.m : MATLAB wrapper function.
- streamlines_uns.cpp         : MEX gateway source.
- tests/                      : MATLAB test scripts and sample data.

Setup
-----
1) Install a supported C/C++ compiler in MATLAB.
   On Windows, you can install "MATLAB Support for MinGW-w64 C/C++/Fortran Compiler"
   from Home -> Add-Ons -> Get Add-Ons.

2) From this folder, compile the MEX function:
   mex streamlines_uns.cpp CXXFLAGS='$CXXFLAGS -fopenmp' LDFLAGS='$LDFLAGS -fopenmp' -I../evenlyspacedstreamlines

3) Run the tests:
   - test_simple.m : basic sanity test (typically ~13 streamlines)
   - test_wind.m   : comparison with MATLAB streamlines for ordered data
   - test_simData.m: larger dataset test

Notes
-----
- The wrapper accepts an `options` struct similar to the Python API.
- When `options.seed_region` is empty (random seeding), rare random failures may occur in MEX.
  The wrapper now retries automatically with `options.max_reruns` attempts (default: 5).

Version-control recommendation
------------------------------
Do not commit compiled binaries (e.g., `.mexw64`, `.mexa64`, `.mexmaci64`).
The repository `.gitignore` includes patterns for these artifacts.
