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
% Author(s): Marleny Vega                                                 %
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

function path = calcTrackingOptimizationPathConstraint(values, phaseout, params)

rootSegmentResidualsPathConstraint = ...
    calcRootSegmentResidualsPathConstraints(params, ...
    phaseout.rootSegmentResiduals);
if strcmp(params.controllerType, 'synergy_driven') 
controllerActuatedMomentsPathConstraint = ...
    calcMuscleActuatedMomentsPathConstraints(params, ...
    phaseout.muscleActuatedMoments, phaseout.muscleJointMoments);
elseif strcmp(params.controllerType, 'torque_driven') 
controllerActuatedMomentsPathConstraint = ...
    calcTorqueActuatedMomentsPathConstraints(params, ...
    phaseout.torqueActuatedMoments, values.controlTorques);
end

path = [rootSegmentResidualsPathConstraint  ...
    controllerActuatedMomentsPathConstraint];
path = scaleToBounds(path, params.maxPath, params.minPath);
end
function rootSegmentResidualsPathConstraint = ...
    calcRootSegmentResidualsPathConstraints(params, rootSegmentResiduals)

isEnabled = valueOrAlternate(params, ...
    "rootSegmentResidualLoadPathConstraint", 0);
rootSegmentResidualsPathConstraint = [];
if isEnabled
    rootSegmentResidualsPathConstraint = rootSegmentResiduals;
end
end
function muscleActuatedMomentsPathConstraint = ...
    calcMuscleActuatedMomentsPathConstraints(params, ...
    muscleActuatedMoments, muscleJointMoments)

isEnabled = valueOrAlternate(params, ...
    "muscleModelLoadPathConstraint", 0);
muscleActuatedMomentsPathConstraint = [];
if isEnabled
    muscleActuatedMomentsPathConstraint = ...
        muscleActuatedMoments - muscleJointMoments;
end
end
function torqueActuatedMomentsPathConstraint = ...
    calcTorqueActuatedMomentsPathConstraints(params, ...
    torqueActuatedMoments, controlTorques)

isEnabled = valueOrAlternate(params, ...
    "controllerModelLoadPathConstraint", 0);
torqueActuatedMomentsPathConstraint = [];
if isEnabled
    torqueActuatedMomentsPathConstraint = ...
        torqueActuatedMoments - controlTorques;
end
end