#include <mex.h>
#include <string.h>
#include <stdio.h>

using namespace std;

void mexFunction (int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
    // bar.info
    const mxArray *bar_info_p;
    char* bar_info_cell_p;
    mwSize total_num_of_info_cells, buflen;
    total_num_of_info_cells = mxGetNumberOfElements(prhs[0]);

    // bar.time
    const mwSize *bar_time_dims;
    double *bar_times;
    bar_times = mxGetPr(prhs[1]);
    bar_time_dims = mxGetDimensions(prhs[1]);

    // bar.signal.time
    const mwSize *bar_signal_time_dims;
    double *bar_signal_times;
    bar_signal_times = mxGetPr(prhs[2]);
    bar_signal_time_dims = mxGetDimensions(prhs[2]);

    // bar.signal.bar
    mxArray *bar_signal_bar;
    double *bar_signal_bar_p;
    plhs[0] = mxCreateDoubleMatrix(bar_signal_time_dims[0], bar_signal_time_dims[1], mxREAL);
    bar_signal_bar = mxCreateDoubleMatrix(bar_signal_time_dims[0], bar_signal_time_dims[1], mxREAL);
    bar_signal_bar_p = mxGetPr(bar_signal_bar);

    mwIndex start_index = 0;
    for (mwIndex i = 0; i < total_num_of_info_cells; i++) {
        bar_info_p = mxGetCell(prhs[0], i);
        buflen = mxGetN(bar_info_p)*sizeof(mxChar)+1;
        bar_info_cell_p = (char*)mxMalloc(buflen);
        mxGetString(bar_info_p, bar_info_cell_p, buflen);
        // mexPrintf("%s\n", bar_info_cell_p);

        if (strcmp(bar_info_cell_p, "bar: true") == 0)
            for (mwIndex j = start_index; j < bar_signal_time_dims[1]; j++) {
                if (bar_signal_times[j] >= bar_times[i])
                    bar_signal_bar_p[j] = 1;
                else {
                    start_index = j;
                    break;
                }
            }
        else if (strcmp(bar_info_cell_p, "bar: false") == 0)
            for (int j = start_index; j < bar_signal_time_dims[1]; j++) {
                if (bar_signal_times[j] > bar_times[i])
                    bar_signal_bar_p[j] = 0;
                else {
                    start_index = j;
                    break;
                }
            }
            else
                for (int j = start_index; j < bar_signal_time_dims[1]; j++) {
                    if (bar_signal_times[j] > bar_times[i])
                        bar_signal_bar_p[j] = -1;
                    else {
                        start_index = j;
                        break;
                    }
                }

        mxFree(bar_info_cell_p);
    }
    plhs[0] = bar_signal_bar;
}
