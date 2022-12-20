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
#define NUMTHREADS 20 //

//______________________________________________________________________________

static Model *osimModel[NUMTHREADS];
static State *osimState[NUMTHREADS];
static InverseDynamicsSolver *idSolver[NUMTHREADS];
static bool modelIsLoaded = false;

void ClearMemory(void)
{
    for (int i = 0; i < NUMTHREADS; i++)
	{
		delete osimModel[i];
		delete idSolver[i];
	}
    
    modelIsLoaded = false;
    mexPrintf("Cleared memory from OpenSimID_OMP mex file.\n");
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    mexAtExit(ClearMemory); // exit function to clear memory allocated in heap
    
    if (nrhs == 1) // Load model if only one right hand side argument
    {    
        if (modelIsLoaded == true){
            ClearMemory();
        }
        string model_name = mxArrayToString(prhs[0]);
      
        std::streambuf* oldCoutStreamBuf = std::cout.rdbuf();
		std::ostringstream strCout;
		std::cout.rdbuf(strCout.rdbuf());

        
        for (int i = 0; i < NUMTHREADS; i++)
		{
			osimModel[i] = new Model(model_name); 
			osimState[i] = &osimModel[i]->initSystem();
			idSolver[i] = new InverseDynamicsSolver(*osimModel[i]);
		}  
        
		std::cout.rdbuf(oldCoutStreamBuf);
        modelIsLoaded = true;
    }
    else if(nrhs == 6) 
    {
        if (modelIsLoaded == false)
        {
            mexErrMsgTxt("!!!No OpenSim model has been loaded!!!\n");
        }
                
		const int numPts = mxGetM(prhs[0]); // get number of rows of time vector
		const int numAngles = mxGetN(prhs[1]); // get number of states (columns in state matrix)
        const int numVels = mxGetN(prhs[2]);
// 		const int numAccels = mxGetN(prhs[3]); // get number of accels
        const int numLabels = mxGetN(prhs[4]);
		const int numControls = mxGetN(prhs[5]); // get number of controls (columns in controls matrix
        
        double *time = mxGetPr(prhs[0]); // time vector
		double *q = mxGetPr(prhs[1]); // states matrix
        double *qp = mxGetPr(prhs[2]); // states matrix
		double *qpp = mxGetPr(prhs[3]); // accelerations matrix
		double *u = mxGetPr(prhs[5]); // controls matrix
        
        const mxArray *cell_element_ptr;
        char* c_array;
        mwIndex i;
        mwSize buflen;
        
        int numCoords = osimState[0]->getNQ();
        plhs[0] = mxCreateDoubleMatrix(numPts,numCoords,mxREAL);
		double *idLoads = mxGetPr(plhs[0]);

        int numMarkers = osimModel[0]->getNumMarkers();       
 		mwSize dimensions[3];
 		dimensions[0] = numPts;
 		dimensions[1] = numMarkers;
 		dimensions[2] = 3; // three coordinates in space per marker
 		plhs[1] = mxCreateNumericArray(3, dimensions, mxDOUBLE_CLASS, mxREAL);
        
 		double* MarkerGlobalPos = mxGetPr(plhs[1]);
         
        #pragma omp parallel for num_threads(NUMTHREADS)
        for (int i=0; i<numPts; ++i)
        {
            int thread_id = omp_get_thread_num();//
            
            for (int k=0; k<numLabels; k++)
            {
                cell_element_ptr = mxGetCell(prhs[4],k);
                buflen = mxGetN(cell_element_ptr)*sizeof(mxChar)+1;
                c_array = (char *)  mxCalloc(buflen, sizeof(char));
                mxGetString(cell_element_ptr,c_array,buflen);
                string c_string(c_array);

                if (!osimModel[thread_id]->getCoordinateSet().get(c_array).get_locked())
                {
                        osimModel[thread_id]->getCoordinateSet().get(c_array).setValue(*osimState[thread_id],q[k*numPts+i]);
                        osimModel[thread_id]->getCoordinateSet().get(c_array).setSpeedValue(*osimState[thread_id],qp[k*numPts+i]);
                }
                mxFree(c_array);
            }

            osimModel[thread_id]->realizeVelocity(*osimState[thread_id]);
            
            double StateQ;
            vector<double> StateQVector;
            std::vector<double>::iterator FoundInd;
            
            for (int j=0;j<numAngles;j++)
			{
                StateQVector.push_back(q[j*numPts+i]); // irow+nrow*icol (column-wise indexing)
            }    
                    
            Vector AccelsVec(numCoords,0.0);
                
            for (int j=0;j<osimState[thread_id]->getNQ();j++)
            {
                StateQ = osimState[thread_id]->getQ().get(j);
                FoundInd = std::find(StateQVector.begin(), StateQVector.end(), StateQ);

                if (FoundInd != StateQVector.cend()) {
                    if (StateQ == 0)
                    {
                        AccelsVec.set(j,0); 
                    }
                    else
                    {
                        AccelsVec.set(j,qpp[std::distance(StateQVector.begin(), FoundInd)*numPts+i]); 
                    }
                }
                else{
                    AccelsVec.set(j,0); 
                }
            }

            Vec3 tempMarkerGlobalPos;
            
            Vector newControls(numControls,0.0);
            
            for (int j=0; j<numControls; j++)
            {
                newControls.set(j,u[i+numPts*j]);
            }
            
            osimModel[thread_id]->setControls(*osimState[thread_id],newControls);
            osimModel[thread_id]->markControlsAsValid(*osimState[thread_id]);
            osimModel[thread_id]->realizeDynamics(*osimState[thread_id]);
            
            Vector IDLoadsVec;
            IDLoadsVec = idSolver[thread_id]->solve(*osimState[thread_id],AccelsVec);
            
            for (int j=0;j<numCoords;j++)
			{
				idLoads[i+numPts*j] = IDLoadsVec[j]; 
			}
        
            for(int j=0; j<numMarkers; j++)
            {
                Marker& tempRefMarker = osimModel[thread_id]->getMarkerSet().get(j);
                const PhysicalFrame& tempRefMarkerParentBody = tempRefMarker.getParentFrame();
                Vec3 tempMarkerLocalPos = tempRefMarker.get_location();
                
                osimModel[thread_id]->getSimbodyEngine().getPosition(*osimState[thread_id], tempRefMarkerParentBody, tempMarkerLocalPos, tempMarkerGlobalPos);

                for (int k=0;k<3;k++)
                {
                    MarkerGlobalPos[numPts*(j+k*numMarkers)+i]=tempMarkerGlobalPos(k);
                }
            }   
                
        }
    }   
}