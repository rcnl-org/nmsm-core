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
#include <InverseDynamicsSolver.h>
#include <string.h>
#include <omp.h> //
#include <matrix.h>
#include <iostream> 
#include <vector>

using namespace OpenSim;
using namespace SimTK;
using namespace std;
#define numThreads 20 //

//______________________________________________________________________________

static Model *osimModel[numThreads];
static State *osimState[numThreads];
static InverseDynamicsSolver *idSolver[numThreads];
static bool modelIsLoaded = false;

void ClearMemory(void){
    for (int i = 0; i < numThreads; i++){
		delete osimModel[i];
		delete idSolver[i];
	}
    modelIsLoaded = false;
    mexPrintf("Cleared memory from inverseDynamics mex file.\n");
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

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]){
    mexAtExit(ClearMemory);
    if (nrhs == 1) {    
        if (modelIsLoaded == true){
            ClearMemory();
        }
        string modelName = mxArrayToString(prhs[0]);      
        std::streambuf* oldCoutStreamBuf = std::cout.rdbuf();
		std::ostringstream strCout;
		std::cout.rdbuf(strCout.rdbuf());
        for (int i = 0; i < numThreads; i++){
			osimModel[i] = new Model(modelName); 
			osimState[i] = &osimModel[i]->initSystem();
			idSolver[i] = new InverseDynamicsSolver(*osimModel[i]);
		}  
		std::cout.rdbuf(oldCoutStreamBuf);
        modelIsLoaded = true;
    }
    else if (nrhs == 6) {
        if (modelIsLoaded == false){
            mexErrMsgTxt("!!!No OpenSim model has been loaded!!!\n");
        }   
		const int numPts = mxGetM(prhs[0]);
        const int numQs = mxGetN(prhs[1]);
		const int numControls = mxGetN(prhs[5]);
        const int numCoords = osimState[0]->getNQ();

        double *time = mxGetPr(prhs[0]);
        vector<vector<double>> q = mexArrayToVector(prhs[1]);
        vector<vector<double>> qp = mexArrayToVector(prhs[2]);
        vector<vector<double>> qpp = mexArrayToVector(prhs[3]);
        vector<vector<double>> u = mexArrayToVector(prhs[5]);

        mwIndex k;
        mwSize numLabels, buflen;
        numLabels = mxGetNumberOfElements(prhs[4]);

        plhs[0] = mxCreateDoubleMatrix(numPts,numCoords,mxREAL);
		double *idLoads = mxGetPr(plhs[0]);
 		plhs[1] = mxCreateDoubleMatrix(numPts, 3, mxREAL);
        double* angularMomentum = mxGetPr(plhs[1]);

        #pragma omp parallel for num_threads(numThreads)
        for (int i = 0; i < numPts; ++i){
            int thread_id = omp_get_thread_num();
            osimState[thread_id]->setTime(time[i]);
			
            for (int k = 0; k < numLabels; k++){
				const mxArray *cellElementPtr;
                cellElementPtr = mxGetCell(prhs[4], k);
                buflen = mxGetN(cellElementPtr)*sizeof(mxChar) + 1;
                char* c_array;
                c_array = (char *)  mxCalloc(buflen, sizeof(char));
                int status = mxGetString(cellElementPtr, c_array, buflen);
                osimModel[thread_id]->getCoordinateSet().get(c_array).setValue(*osimState[thread_id], q[i][k], false);
                osimModel[thread_id]->getCoordinateSet().get(c_array).setSpeedValue(*osimState[thread_id], qp[i][k]);
                mxFree(c_array);
            }

            osimModel[thread_id]->realizeVelocity(*osimState[thread_id]);
            if (nlhs > 1) {
                SpatialVec momentum = osimModel[thread_id]->getMatterSubsystem().calcSystemCentralMomentum(*osimState[thread_id]);
                Vec3 angularMomentumPoint = momentum.get(0);
                for (int j = 0; j <= 2; j++) {
                    angularMomentum[i + numPts * j] = angularMomentumPoint.get(j);
                }
            }

            Vector AccelsVec(numCoords, 0.0);
            for (int j = 0; j < numCoords; j++){
                double StateQ = osimState[thread_id]->getQ().get(j);
                for (int k = 0; k < numQs; k++){
                    if (abs(q[i][k] - StateQ) <= 1e-6){
                        AccelsVec.set(j, qpp[i][k]);
                    }
                }
            }

            Vector newControls(numControls, 0.0);
            for (int j = 0; j < numControls; j++){
                newControls.set(j, u[i][j]);
            }
            osimModel[thread_id]->setControls(*osimState[thread_id], newControls);
            osimModel[thread_id]->markControlsAsValid(*osimState[thread_id]);
            osimModel[thread_id]->realizeDynamics(*osimState[thread_id]);
            
            Vector IDLoadsVec;
            IDLoadsVec = idSolver[thread_id]->solve(*osimState[thread_id], AccelsVec);
            for (int j = 0; j < numCoords; j++){
				idLoads[i + numPts * j] = IDLoadsVec[j]; 
			}
        }
		//q.clear();
		//qp.clear();
		//qpp.clear();
		//u.clear();
    }   
}