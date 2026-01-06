#include "mex.h"
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <OpenSim/OpenSim.h>
#include <omp.h>

using namespace OpenSim;
using namespace SimTK;
using namespace std;
#define NTHREADS 20

//______________________________________________________________________________


static Model *osimModel[NTHREADS];
static State *osimState[NTHREADS];
static bool modelIsLoaded = false;

void ClearMemory(void)
{
	for (int i = 0; i<NTHREADS; ++i)
		delete osimModel[i];
	modelIsLoaded = false;
	mexPrintf("Cleared memory from opensimPointKin mex file.\n");
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{

	mexAtExit(ClearMemory); // exit function to clear memory allocated in heap

	if (nrhs == 1) // Load model if only one right hand side argument
	{
		if (modelIsLoaded == true) {
			ClearMemory();
		}
		string model_name = mxArrayToString(prhs[0]);

		std::streambuf* oldCoutStreamBuf = std::cout.rdbuf();
		std::ostringstream strCout;
		std::cout.rdbuf(strCout.rdbuf());

		for (int i = 0; i < NTHREADS; ++i)
		{
			osimModel[i] = new Model(model_name);
			osimState[i] = &osimModel[i]->initSystem();
		}

		std::cout.rdbuf(oldCoutStreamBuf);
		modelIsLoaded = true;
	}
	else if (nrhs == 6)
	{
		if (modelIsLoaded == false)
		{
			mexErrMsgTxt("!!!No OpenSim model has been loaded!!!\n");
		}

		const int numPts = mxGetM(prhs[0]); // get number of rows of time vector
		const int numSprings = mxGetN(prhs[3]); // get number of bodies springs are located on
		const int numLabels = mxGetN(prhs[5]);

		double *time = mxGetPr(prhs[0]); // time vector
		double *q = mxGetPr(prhs[1]); // joint angles matrix
		double *qp = mxGetPr(prhs[2]); // joint velocities matrix
		double *SpringMat = mxGetPr(prhs[3]); // spring locations within body
		double *SpringBodyMat = mxGetPr(prhs[4]); // body number index for springs

		OpenSim::BodySet *refBodySet[NTHREADS];
		for (int i = 0; i<NTHREADS; ++i)
		{
			refBodySet[i] = &osimModel[i]->updBodySet();
		}

		mwSize dims[3];
		dims[0] = numPts;
		dims[1] = 3;
		dims[2] = numSprings;
		plhs[0] = mxCreateNumericArray(3, dims, mxDOUBLE_CLASS, mxREAL);
		plhs[1] = mxCreateNumericArray(3, dims, mxDOUBLE_CLASS, mxREAL);
		//plhs[0] = mxCreateDoubleMatrix(numPts * numSprings, 3, mxREAL);
		//plhs[1] = mxCreateDoubleMatrix(numPts * numSprings, 3, mxREAL);
		double *sp_pos = mxGetPr(plhs[0]);
		double *sp_vel = mxGetPr(plhs[1]);
		
        mwIndex k;
		mwSize buflen;

		#pragma omp parallel for num_threads(NTHREADS)
		for (int i = 0; i<numPts; ++i)
		{
			int thread_id = omp_get_thread_num();
            osimState[thread_id]->setTime(time[i]);

            for (int k = 0; k < numLabels; k++){
				const mxArray *cell_element_ptr;
                cell_element_ptr = mxGetCell(prhs[5], k);
				buflen = mxGetN(cell_element_ptr) * sizeof(mxChar) + 1;
        		char* c_array;
				c_array = (char *)mxCalloc(buflen, sizeof(char));
				mxGetString(cell_element_ptr, c_array, buflen);
				string c_string(c_array);

				if (!osimModel[thread_id]->getCoordinateSet().get(c_array).get_locked())
				{
                    //
					osimModel[thread_id]->getCoordinateSet().get(c_array).setValue(*osimState[thread_id], q[k*numPts + i], false);
					osimModel[thread_id]->getCoordinateSet().get(c_array).setSpeedValue(*osimState[thread_id], qp[k*numPts + i]);
				}
				mxFree(c_array);
            }
			
            osimModel[thread_id]->realizeVelocity(*osimState[thread_id]);

			for (int j = 0; j<numSprings; j++)
			{
				OpenSim::Body& tempRefParentBody = refBodySet[thread_id]->get(SpringBodyMat[j]);
				Vec3 tempLocalPos;
				tempLocalPos.set(0, SpringMat[j * 3]);
				tempLocalPos.set(1, SpringMat[j * 3 + 1]);
				tempLocalPos.set(2, SpringMat[j * 3 + 2]);

				Vec3 tempGlobalPos;
				Vec3 tempGlobalVel;

				osimModel[thread_id]->getSimbodyEngine().getPosition(*osimState[thread_id], tempRefParentBody, tempLocalPos, tempGlobalPos);
				osimModel[thread_id]->getSimbodyEngine().getVelocity(*osimState[thread_id], tempRefParentBody, tempLocalPos, tempGlobalVel);
				
				sp_pos[i + j * numPts * 3 + numPts * 0] = tempGlobalPos(0);
				sp_pos[i + j * numPts * 3 + numPts * 1] = tempGlobalPos(1);
				sp_pos[i + j * numPts * 3 + numPts * 2] = tempGlobalPos(2);

				sp_vel[i + j * numPts * 3 + numPts * 0] = tempGlobalVel(0);
				sp_vel[i + j * numPts * 3 + numPts * 1] = tempGlobalVel(1);
				sp_vel[i + j * numPts * 3 + numPts * 2] = tempGlobalVel(2);
				
			}
		}
	}
}