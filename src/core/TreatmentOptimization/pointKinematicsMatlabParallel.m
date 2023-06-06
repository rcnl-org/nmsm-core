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

function [SpringPos, SpringVel] = pointKinematicsMatlabParallel(time,q,qp,SpringMat,SpringBodyMat,...
    modelFile,IKLabels)

% Get the number of coords and markers
numPts = size(time,1);
numSprings = size(SpringMat,1);

% Split time points into parallel problems
numWorkers = gcp().NumWorkers;
SpringPosJobs = cell(1, numWorkers);
SpringVelJobs = cell(1, numWorkers);

parfor worker = 1:numWorkers
    [SpringPosJobs{worker}, SpringVelJobs{worker}] = pointKinematicsWorkerHelper(modelFile, numPts, numSprings, numWorkers, time,q,qp,SpringMat,SpringBodyMat,IKLabels,worker);
end

SpringPos = SpringPosJobs{1};
SpringVel = SpringVelJobs{1};
for job = 2 : numWorkers
    SpringPos = cat(1, SpringPos, SpringPosJobs{job});
    SpringVel = cat(1, SpringVel, SpringVelJobs{job});
end

end

function [SpringPosJob, SpringVelJob] = pointKinematicsWorkerHelper(modelFile, numPts, numSprings, numWorkers, time,q,qp,SpringMat,SpringBodyMat,IKLabels,worker)

    import org.opensim.modeling.*;
    persistent osimModel;
    persistent osimState;
    persistent refBodySet;
    if isempty(osimModel)
        osimModel = Model(modelFile);
        osimState = osimModel.initSystem();
        refBodySet = osimModel.getBodySet;
    end

    SpringPosJob = zeros(length(1 + (worker - 1) * ceil(numPts / numWorkers) : min(worker * ceil(numPts / numWorkers), numPts)), numSprings * 3);
    SpringVelJob = zeros(length(1 + (worker - 1) * ceil(numPts / numWorkers) : min(worker * ceil(numPts / numWorkers), numPts)), numSprings * 3);
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

        for i=1:numSprings
            tempRefParentBody = refBodySet.get(SpringBodyMat(i));
            tempLocalPos = Vec3(3,0);
            tempGlobalPos = Vec3(3,0);
            tempGlobalVel = Vec3(3,0);
            tempLocalPos.set(0,SpringMat(i,1));
            tempLocalPos.set(1,SpringMat(i,2));
            tempLocalPos.set(2,SpringMat(i,3));

            osimModel.getSimbodyEngine.getPosition(osimState,tempRefParentBody,tempLocalPos,tempGlobalPos);
            osimModel.getSimbodyEngine.getVelocity(osimState,tempRefParentBody,tempLocalPos,tempGlobalVel);

            for k=0:2
                SpringPosJob(j-indexOffset,(i-1)*3+k+1)=tempGlobalPos.get(k);
                SpringVelJob(j-indexOffset,(i-1)*3+k+1)=tempGlobalVel.get(k);
            end
        end
    end

end
