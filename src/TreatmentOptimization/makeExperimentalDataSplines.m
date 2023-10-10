% This function is part of the NMSM Pipeline, see file for full license.
%
% This function calculates the splines for all experimental data. These
% splines are evaluated at the collocation points to allow tracking of
% these quanitites during treatment optimization
%
% (struct) -> (struct)
% Calculates the splines for all experimental data

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Marleny Vega, Claire V. Hammond                              %
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

function inputs = makeExperimentalDataSplines(inputs)
inputs.splineJointAngles = spaps(inputs.experimentalTime, ...
    inputs.experimentalJointAngles', 0.0000001);
inputs.splineJointVelocities = spaps(inputs.experimentalTime, ...
    inputs.experimentalJointVelocities', 0.0000001);
inputs.splineJointAccelerations = spaps(inputs.experimentalTime, ...
    inputs.experimentalJointAccelerations', 0.0000001);
inputs.splineJointMoments = spaps(inputs.experimentalTime, ...
    inputs.experimentalJointMoments', 0.0000001);
if strcmp(inputs.controllerType, 'synergy')
inputs.splineMuscleActivations = spaps(inputs.experimentalTime, ...
    inputs.experimentalMuscleActivations', 0.0000001);
end
for i = 1:length(inputs.contactSurfaces)
    inputs.splineExperimentalGroundReactionForces{i} = ...
        spaps(inputs.experimentalTime, ...
        inputs.contactSurfaces{i}.experimentalGroundReactionForces', 0.0000001);
    inputs.splineExperimentalGroundReactionMoments{i} = ...
        spaps(inputs.experimentalTime, ...
        inputs.contactSurfaces{i}.experimentalGroundReactionMoments', 0.0000001);
end
end