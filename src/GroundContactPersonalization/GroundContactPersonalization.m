% This function is part of the NMSM Pipeline, see file for full license.
%
% 
%
% (struct, struct) -> (struct)
% Runs all Ground Contact Personalization stages from inputs and params.

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Claire V. Hammond, Spencer Williams                          %
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

function results = GroundContactPersonalization(inputs, params)
inputs = prepareGroundContactPersonalizationInputs(inputs, params);
% Optionally initializes the resting spring length.
if params.restingSpringLengthInitialization
    inputs = initializeRestingSpringLength(inputs);
end
for task = 1:length(inputs.tasks)
    inputs.tasks{task}.experimentalGroundReactionMoments = ...
        replaceMomentsAboutMidfootSuperior(inputs.tasks{task}, inputs);
    inputs.tasks{task}.experimentalGroundReactionMomentsSlope = ...
        calcBSplineDerivative(inputs.tasks{task}.time, ...
        inputs.tasks{task}.experimentalGroundReactionMoments, 2, ...
        inputs.tasks{task}.splineNodes);
end
% Run each task as outlined in XML settings file. 
for task = 1:length(params.tasks)
    inputs = optimizeGroundContactPersonalizationTask(inputs, params, ...
        task);
end

results = inputs;
end

% (struct) -> (2D Array of double)
% Replace parsed experimental ground reaction moments about midfoot
% superior marker projected onto floor
function replacedMoments = replaceMomentsAboutMidfootSuperior(task, inputs)
    replacedMoments = ...
        zeros(size(task.experimentalGroundReactionMoments));
    for i = 1:size(replacedMoments, 2)
        newCenter = task.midfootSuperiorPosition(:, i);
        newCenter(2) = inputs.restingSpringLength;
        replacedMoments(:, i) = ...
            task.experimentalGroundReactionMoments(:, i) + ...
            cross((task.electricalCenter(:, i) - newCenter), ...
            task.experimentalGroundReactionForces(:, i));
    end
end
