% This function is part of the NMSM Pipeline, see file for full license.
%
% This function calculates the new kinematic curves from the experimental
% data and deviation values.
%
% jointKinematicsBSplines is a struct with 2 fields (position, velocity)
% as comes out of makeJointKinematicsBSplines(). The output
% struct has matching fields.
%
% (2D Array of double, struct, 2D Array of double) -> (struct)
% Calculate new joint kinematics curves from data and deviations curves

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Claire V. Hammond                                            %
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

function [modeledJointPositions, modeledJointVelocities] = ...
    calcGCPJointKinematics(experimentalJointPositions, ...
    jointKinematicsBSplines, deviationNodes)
nodes = jointKinematicsBSplines.position \ experimentalJointPositions';
fittedNodes = nodes .* deviationNodes;

modeledJointPositions = jointKinematicsBSplines.position * fittedNodes;
modeledJointVelocities = jointKinematicsBSplines.velocity * fittedNodes;
modeledJointPositions = modeledJointPositions';
modeledJointVelocities = modeledJointVelocities';
end

