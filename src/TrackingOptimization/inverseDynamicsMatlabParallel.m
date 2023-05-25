% This function is part of the NMSM Pipeline, see file for full license.
%
% () -> ()
%

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Spencer Williams                                             %
%                                                                         %
% Licensed under the Apache License, Version 2.0 (the "License");         %
% you may not use this file except in compliance with the License.        %
% You may obtain a copy of the License at                                 %
% http://www.apache.org/licenses/LICENSE-2.0.                             %
%                                                                         %
% Unless required by applicable law or agreed to in writing, software     %
% distributed under the License is distributed on an "AS IS" BASIS,       %
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or         %
% implied. See the License for the specific language governing            %
% permissions and limitations under the License.                          %
% ----------------------------------------------------------------------- %

function IDLoads = inverseDynamicsMatlabParallel(time,q,qp,qpp,IKLabels,AppliedLoads,modelFile)

% Get the number of coords and markers
numPts = size(time,1);
numControls = size(AppliedLoads,2);
numCoords = length(IKLabels);

% Split time points into parallel problems
numWorkers = gcp().NumWorkers;
IDLoadsJobs = cell(1, numWorkers);
AccelsTempVec = cell(1, numWorkers);

parfor worker = 1:numWorkers
    IDLoadsJobs{worker} = idWorkerHelper(modelFile, numPts, numControls, numCoords, numWorkers, AccelsTempVec{worker},time,q,qp,qpp,IKLabels,AppliedLoads,worker);
end

IDLoads = IDLoadsJobs{1};
for job = 2 : numWorkers
    IDLoads = cat(1, IDLoads, IDLoadsJobs{job});
end

end

function IDLoadsJob = idWorkerHelper(modelFile, numPts, numControls, numCoords, numWorkers, AccelsTempVec,time,q,qp,qpp,IKLabels,AppliedLoads,worker)
    
    import org.opensim.modeling.*;
    persistent osimModel;
    persistent osimState;
    persistent idSolver;
    if isempty(osimModel)
        osimModel = Model(modelFile);
        osimState = osimModel.initSystem();
        idSolver = InverseDynamicsSolver(osimModel);
    end

    IDLoadsJob = [];

    indexOffset = (worker - 1) * ceil(numPts / numWorkers);

    for j = 1 + (worker - 1) * ceil(numPts / numWorkers) : min(worker * ceil(numPts / numWorkers), numPts)
        osimState.setTime(time(j,1));
        for k=1:size(IKLabels,2)
            if ~osimModel.getCoordinateSet.get(IKLabels{k}).get_locked
                osimModel.getCoordinateSet.get(IKLabels{k}).setValue(osimState,q(j,k));
                osimModel.getCoordinateSet.get(IKLabels{k}).setSpeedValue(osimState,qp(j,k));
            end
        end
        osimModel.realizeVelocity(osimState);

        for i=1:osimState.getNQ
            StateQ = osimState.getQ.get(i-1);

            for ii = 1:size(q,2)
                if abs(q(j,ii)-StateQ) <= 1e-6
                    AccelsTempVec(j-indexOffset,i) = qpp(j,ii);
                end
            end
        end

        newControls = Vector(numControls,0);

        for i=0:numControls-1
            newControls.set(i,AppliedLoads(j,i+1));
        end

        osimModel.setControls(osimState,newControls);
        osimModel.markControlsAsValid(osimState);
        osimModel.realizeDynamics(osimState);

        AccelsVec = Vector(osimState.getNQ,0);

        includedQIndex = 1;
        for i=0:osimState.getNQ-1
            currentCoordinate = osimModel.getCoordinateSet().get(i).getName().toCharArray';
            if any(cellfun(@isequal, IKLabels, repmat({currentCoordinate}, 1, length(IKLabels))))
                AccelsVec.set(i,AccelsTempVec(j-indexOffset,includedQIndex));
                includedQIndex = includedQIndex + 1;
            end
        end

        IDLoadsVec = idSolver.solve(osimState,AccelsVec);

        for i=0:numCoords-1
            IDLoadsJob(j-indexOffset,i+1) = IDLoadsVec.get(i);
        end
    end

end
