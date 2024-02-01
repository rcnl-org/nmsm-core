// This function is part of the NMSM Pipeline, see file for full license.
//
// performs inverse dynamics with openMP

// ----------------------------------------------------------------------- //
// The NMSM Pipeline is a toolkit for model personalization and treatment  //
// optimization of neuromusculoskeletal models through OpenSim. See        //
// nmsm.rice.edu and the NOTICE file for more information. The             //
// NMSM Pipeline is developed at Rice University and supported by the US   //
// National Institutes of Health (R01 EB030520).                           //
//                                                                         //
// Copyright (c) 2021 Rice University and the Authors                      //
// Author(s): Marleny Vega                                                 //
//                                                                         //
// Licensed under the Apache License, Version 2.0 (the "License");         //
// you may not use this file except in compliance with the License.        //
// You may obtain a copy of the License at                                 //
// http://www.apache.org/licenses/LICENSE-2.0.                             //
//                                                                         //
// Unless required by applicable law or agreed to in writing, software     //
// distributed under the License is distributed on an "AS IS" BASIS,       //
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or         //
// implied. See the License for the specific language governing            //
// permissions and limitations under the License.                          //
// ----------------------------------------------------------------------- //

#include "mex.h"
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <OpenSim/OpenSim.h>
#include <GCVSplineSet.h>
#include <string.h>
#include <omp.h>
#include <matrix.h>
#include <iostream> 
#include <vector>
#include <io.h>
#include <process.h>
#include <windows.h>

using namespace OpenSim;
using namespace SimTK;
using namespace std;

//______________________________________________________________________________


void ClearMemory(void){
}

vector<vector<double>> mexArrayToVector(const mxArray *input) {
    const mwSize *dimension;
    dimension = mxGetDimensions(input);
    int rows = (int) dimension[0];
    int columns = (int) dimension[1];
    double *data = (double *) mxGetData(input);
    vector<vector<double>> output(rows, vector<double>(columns));
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < columns; j++) {
            memcpy(&output[i][j], data + i + j * rows, sizeof(double) );
        }
    }
    return output;
}

vector<int> mexArrayToVectorInt(const mxArray *input, int numPts) {
    int *data = (int *) mxGetData(input);
    vector<int> output(numPts);
    for (int i = 0; i < numPts; i++) {
        memcpy(&output[i], data + i, sizeof(int) );
    }
    return output;
}

vector<double> mexArrayToVectorDouble(const mxArray *input, int numPts) {
    double *data = (double *) mxGetData(input);
    vector<double> output(numPts);
    for (int i = 0; i < numPts; i++) {
        memcpy(&output[i], data + i, sizeof(double) );
    }
    return output;
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]){
    mexAtExit(ClearMemory);
    if (nrhs == 4) {
        const int numColumns = mxGetN(prhs[1]);
		const int numPts = mxGetN(prhs[2]);

        vector<int> columns = mexArrayToVectorInt(prhs[1], numColumns);
        vector<double> time = mexArrayToVectorDouble(prhs[2], numPts);

        GCVSplineSet *splineSet = (GCVSplineSet *) mxGetPr(prhs[0]);
        int *derivative = (int *) mxGetPr(prhs[3]);

        plhs[0] = mxCreateDoubleMatrix(numPts,numColumns,mxREAL);
		double *values = mxGetPr(plhs[0]);

        for (int i = 0; i < numColumns; ++i) {
            for (int j = 0; j < numPts; ++i) {
                values[j + numPts * i] = splineSet->evaluate(columns[i], *derivative, time[j]);
            }
        }

		columns.clear();
		time.clear();
    }   
}