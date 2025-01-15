#include "engine.cpp"
#include "mex.h"

// To compile in matlab: mex filename.cpp CXXFLAGS='$CXXFLAGS -fopenmp' LDFLAGS='$LDFLAGS -fopenmp' -I../evenlyspacedstreamlines
// To run in matlab prova_mex()
void mexFunction(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[])
{
    // if (nrhs != 4) {
    //     mexErrMsgIdAndTxt("MATLAB:run_engine_mex:invalidNumInputs",
    //                       "Four inputs required: vertices, triangles, orientation, and radius.");
    // }
    
    // Input parsing
    
    //mexPrintf("\nParsing\n");
    double *vertices = mxGetPr(prhs[0]);
    int *triangles = (int *) mxGetData(prhs[1]);
    double *orientation = mxGetPr(prhs[2]);
    double radius = mxGetScalar(prhs[3]);
    int orthogonal = mxGetScalar(prhs[4]);
    int oriented_streamlines= mxGetScalar(prhs[5]);
    int seed_points= mxGetScalar(prhs[6]);
    int *seed_region = (int *) mxGetPr(prhs[7]);
    double max_length= mxGetScalar(prhs[8]);
    int avoid_u_turns= mxGetScalar(prhs[9]);
    double max_angle= mxGetScalar(prhs[10]);
    double singularity_mask_radius= mxGetScalar(prhs[11]);
    int allow_tweaking_orientation= mxGetScalar(prhs[12]);
    int random_seed= mxGetScalar(prhs[13]);
    int parallel= mxGetScalar(prhs[14]);
    int num_threads= mxGetScalar(prhs[15]);
    

    size_t nv = mxGetN(prhs[0]);
    size_t nt = mxGetN(prhs[1]);
    size_t nr = mxGetM(prhs[7]);

    //mexPrintf("\nnv = %d, nt = %d, nr = %d\n",nv,nt,nr);

    // Initialize engine
    //mexPrintf("\nInitializing engine\n");
    StreamlineEngine engine;
    engine.initialize(nv, nt, vertices, triangles, orientation, orthogonal, allow_tweaking_orientation);
    
    if (engine.error_code == 3) {
        mexErrMsgIdAndTxt("MATLAB:streamlines_uns:nonManifold",
                          engine.error_message.c_str());
    }
    
    // Setup engine
    engine.setup(radius, nt, seed_points, avoid_u_turns, max_angle, oriented_streamlines, singularity_mask_radius, random_seed, parallel, num_threads);
    
    if (nr>1)
    {
        engine.define_seed_region(nr, seed_region);
    }
    
    if (engine.error_code==1)
    {
        mexErrMsgIdAndTxt("MATLAB:streamlines_uns:TriangleArea",
                          "Negative triangle area detected.");
    }
    else if (engine.error_code==2)
    {
        mexErrMsgIdAndTxt("MATLAB:streamlines_uns:Orientation",
                          "At least one orientation vector is parallel to an edge of its corresponding triangle or has zero norm. Try with 'allow_tweaking_orientation=True'");
    }
    // Run engine
    engine.run();
    
    // Retrieve results
    //mexPrintf("\nRetrieve results\n");
    int ns = engine.get_nb_streamlines();
    //mexPrintf("\nNumber of streamlines = %d\n",ns);
    plhs[0] = mxCreateCellMatrix(ns, 1);
    for (int i = 0; i < ns; ++i) {
        int n = engine.get_streamline_size(i);
        mxArray *line = mxCreateDoubleMatrix(3*n, 1, mxREAL);
        double *lineData = mxGetPr(line);
        std::vector<int> indices(n - 1);
        engine.get_streamline(i, lineData, indices.data());
        mxSetCell(plhs[0], i, line);
    }

}