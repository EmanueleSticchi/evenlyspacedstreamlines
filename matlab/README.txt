To set up:

1) Compile the mex function: mex streamlines_uns.cpp CXXFLAGS='$CXXFLAGS -fopenmp' LDFLAGS='$LDFLAGS -fopenmp' -I../evenlyspacedstreamlines
2) Run test_simple.m to see if it succesfully run on a simple case. It should generate around 13 streamlines.
3) Run test_wind.m to see if it succesfully compare with matlab streamlines function for ordered data.