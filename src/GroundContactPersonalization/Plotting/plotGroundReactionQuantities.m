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

function plotGroundReactionQuantities(inputs, params, task)

plotParams = params;
plotParams.tasks{task}.costTerms.verticalGrfError.isEnabled = true;
plotParams.tasks{task}.costTerms.horizontalGrfError.isEnabled = true;
plotParams.tasks{task}.costTerms.groundReactionMomentError.isEnabled = true;

[modeledJointPositions, modeledJointVelocities] = ...
    calcGCPJointKinematics(inputs.experimentalJointPositions, ...
    inputs.jointKinematicsBSplines, inputs.bSplineCoefficients);
modeledValues = calcGCPModeledValues(inputs, inputs, ...
    modeledJointPositions, modeledJointVelocities, plotParams, task);
modeledValues.jointPositions = modeledJointPositions;
modeledValues.jointVelocities = modeledJointVelocities;

groundReactions = ["verticalGrf", "anteriorGrf", "lateralGrf", ...
    "xGrfMoment", "yGrfMoment", "zGrfMoment"];
subplot(2, 3, 1)
scatter(inputs.time, ...
    inputs.experimentalGroundReactionForces(2, :), [], "red")
hold on
scatter(inputs.time, modeledValues.verticalGrf, [], "blue")
error = rms(inputs.experimentalGroundReactionForces(2, :) - ...
    modeledValues.verticalGrf);
title(groundReactions(1) + newline + " RMSE: " + error)
xlabel('Time')
ylabel('Force (N)')
hold off

for i = 2:6
    subplot(2, 3, i)
    if (i == 2)
        scatter(inputs.time, ...
            inputs.experimentalGroundReactionForces(1, :), [], "red")
        hold on
        scatter(inputs.time, modeledValues.(groundReactions(i)), [], ...
            "blue")
        error = rms(inputs.experimentalGroundReactionForces(1, :) - ...
            modeledValues.(groundReactions(i)));
        title(groundReactions(i) + newline + " RMSE: " + error)
        xlabel('Time')
        hold off
    elseif (i == 3)
        scatter(inputs.time, ...
            inputs.experimentalGroundReactionForces(i, :), [], "red")
        hold on
        scatter(inputs.time, modeledValues.(groundReactions(i)), [], ...
            "blue")
        error = rms(inputs.experimentalGroundReactionForces(i, :) - ...
            modeledValues.(groundReactions(i)));
        title(groundReactions(i) + newline + " RMSE: " + error)
        xlabel('Time')
        hold off
    else
        scatter(inputs.time, ...
            inputs.experimentalGroundReactionMoments(i - 3, :), [], ...
            "red")
        hold on
        scatter(inputs.time, modeledValues.(groundReactions(i)), ...
            [], "blue")
        error = rms(inputs.experimentalGroundReactionMoments(i - 3, :) - ...
            modeledValues.(groundReactions(i)));
        title(groundReactions(i) + newline + " RMSE: " + error)
        xlabel('Time')
        if i == 4
            ylabel('Moment (N*m)')
        end
        hold off
    end
end

end