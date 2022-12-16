% This function is part of the NMSM Pipeline, see file for full license.
%
% 
%
% (Model, struct, string, string) -> (None)
% Plot optimized ground reaction quantities from GCP.

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

function plotGroundReactionQuantities(inputs, lastStage)
[modeledJointPositions, modeledJointVelocities] = ...
    calcGCPJointKinematics(inputs.experimentalJointPositions, ...
    inputs.jointKinematicsBSplines, inputs.bSplineCoefficients);
modeledValues = calcGCPModeledValues(inputs, inputs, ...
    modeledJointPositions, modeledJointVelocities, [1, 1, ...
    (lastStage >= 2), (lastStage == 3)], params);
modeledValues.jointPositions = modeledJointPositions;
modeledValues.jointVelocities = modeledJointVelocities;


groundReactions = ["verticalGrf", "anteriorGrf", "lateralGrf", ...
    "xGrfMoment", "yGrfMoment", "zGrfMoment"];
if lastStage >= 2
    subplot(lastStage - 1, 3, 1)
end
scatter(inputs.time, ...
    inputs.experimentalGroundReactionForces(2, :), [], "red")
hold on
scatter(inputs.time, modeledValues.verticalGrf, [], "blue")
title(groundReactions(1))
xlabel('Time')
ylabel('Force (N)')
hold off

if lastStage >= 2
    for i = 2:6
        subplot(lastStage - 1, 3, i)
        if (i == 2)
            scatter(inputs.time, ...
                inputs.experimentalGroundReactionForces(1, :), [], "red")
            hold on
            scatter(inputs.time, modeledValues.(groundReactions(i)), [], ...
                "blue")
            title(groundReactions(i))
            xlabel('Time')
            hold off
        elseif (i == 3)
            scatter(inputs.time, ...
                inputs.experimentalGroundReactionForces(i, :), [], "red")
            hold on
            scatter(inputs.time, modeledValues.(groundReactions(i)), [], ...
                "blue")
            title(groundReactions(i))
            xlabel('Time')
            hold off
        else
            scatter(inputs.time, ...
                inputs.experimentalGroundReactionMoments(i - 3, :), [], ...
                "red")
            hold on
            scatter(inputs.time, modeledValues.(groundReactions(i)), ...
                [], "blue")
            title(groundReactions(i))
            xlabel('Time')
            if i == 4
                ylabel('Moment (N*m)')
            end
            hold off
        end
    end
end

end
