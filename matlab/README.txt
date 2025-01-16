To set up:
0) Install MinGW-w64 Compiler in Matlab: in 'HOME' tab, click Add-Ons->Get Add-Ons. Install 'MATLAB Support for MinGW-w64 C/C++/Fortran Compiler'.
1) Compile the mex function: mex streamlines_uns.cpp CXXFLAGS='$CXXFLAGS -fopenmp' LDFLAGS='$LDFLAGS -fopenmp' -I../evenlyspacedstreamlines
2) Run test_simple.m to see if it succesfully run on a simple case. It should generate around 13 streamlines.
3) Run test_wind.m to see if it succesfully compare with matlab streamlines function for ordered data.
3) Run test_simData.m to see if it works with larger data sets.