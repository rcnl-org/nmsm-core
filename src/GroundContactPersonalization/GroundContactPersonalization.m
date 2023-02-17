% This function is part of the NMSM Pipeline, see file for full license.
%
% 
%
% (struct, struct) -> (struct)
% Optimize ground contact parameters according to Jackson et al. (2016)

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
verifyInputs(inputs); % (struct) -> (None)
verifyParams(params); % (struct) -> (None)
inputs = prepareGroundContactPersonalizationInputs(inputs, params);
inputs = initializeRestingSpringLengthAndSpringConstants(inputs);
for task = 1:length(inputs.tasks)
    inputs.tasks{task}.experimentalGroundReactionMoments = ...
        replaceMomentsAboutMidfootSuperior(inputs.tasks{task}, inputs);
    inputs.tasks{task}.experimentalGroundReactionMomentsSlope = ...
        calcBSplineDerivative(inputs.tasks{task}.time, ...
        inputs.tasks{task}.experimentalGroundReactionMoments, 2, ...
        inputs.tasks{task}.splineNodes);
end
params = prepareGroundContactPersonalizationParams(params);

for task = 1:length(params.tasks)
    taskInputs = prepareGroundContactPersonalizationInputs(inputs, params);
    taskParams = prepareGroundContactPersonalizationParams(params);
    inputs = optimizeGroundContactPersonalizationTask(inputs, params, task);
end

results = inputs;
end

% (struct) -> (None)
% throws an error if any of the inputs are invalid
function verifyInputs(inputs)

end

% (struct) -> (None)
% throws an error if the parameter is included but is not of valid type
function verifyParams(params)

end

function params = prepareGroundContactPersonalizationParams(params)
    for task = 1:length(params.tasks)
        params.tasks{task}.costTerms.springConstantErrorFromNeighbors.standardDeviation = valueOrAlternate(params, 'nothere', 0.03);
    end
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
