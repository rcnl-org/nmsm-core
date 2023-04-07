% This function is part of the NMSM Pipeline, see file for full license.
%
%
%
% (struct, struct, double, double) -> (None)
% Plot optimized ground reaction quantities from GCP from workspace data.

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

function plotGroundReactionQuantities(inputs, params, task, foot)

plotParams = params;
% plotParams.tasks{task}.costTerms.verticalGrfError.isEnabled = true;
% plotParams.tasks{task}.costTerms.horizontalGrfError.isEnabled = true;
% plotParams.tasks{task}.costTerms.groundReactionMomentError.isEnabled = true;

for i = 1:length(inputs.surfaces)
    models.("model_" + i) = Model(inputs.surfaces{foot}.model);
end
[modeledJointPositions, modeledJointVelocities] = ...
    calcGCPJointKinematics(inputs.surfaces{foot}.experimentalJointPositions, ...
    inputs.surfaces{foot}.jointKinematicsBSplines, inputs.surfaces{foot}.bSplineCoefficients);
modeledValues = calcGCPModeledValues(inputs, inputs, ...
    modeledJointPositions, modeledJointVelocities, plotParams, task, ...
    foot, models);
modeledValues.jointPositions = modeledJointPositions;
modeledValues.jointVelocities = modeledJointVelocities;

groundReactions = ["verticalGrf", "anteriorGrf", "lateralGrf", ...
    "xGrfMoment", "yGrfMoment", "zGrfMoment"];
subplot(2, 3, 1)
plot(inputs.surfaces{foot}.time, ...
    inputs.surfaces{foot}.experimentalGroundReactionForces(2, :), "red", "LineWidth", 2)
hold on
plot(inputs.surfaces{foot}.time, modeledValues.verticalGrf, "blue", "LineWidth", 2)
error = rms(inputs.surfaces{foot}.experimentalGroundReactionForces(2, :) - ...
    modeledValues.verticalGrf);
title(groundReactions(1) + newline + " RMSE: " + error)
xlabel('Time')
ylabel('Force (N)')
hold off

for i = 2:6
    subplot(2, 3, i)
    if (i == 2)
        plot(inputs.surfaces{foot}.time, ...
            inputs.surfaces{foot}.experimentalGroundReactionForces(1, :), "red", ...
            "LineWidth", 2)
        hold on
        plot(inputs.surfaces{foot}.time, modeledValues.(groundReactions(i)), ...
            "blue", "LineWidth", 2)
        error = rms(inputs.surfaces{foot}.experimentalGroundReactionForces(1, :) - ...
            modeledValues.(groundReactions(i)));
        title(groundReactions(i) + newline + " RMSE: " + error)
        xlabel('Time')
        hold off
    elseif (i == 3)
        plot(inputs.surfaces{foot}.time, ...
            inputs.surfaces{foot}.experimentalGroundReactionForces(i, :), "red", ...
            "LineWidth", 2)
        hold on
        plot(inputs.surfaces{foot}.time, modeledValues.(groundReactions(i)), ...
            "blue", "LineWidth", 2)
        error = rms(inputs.surfaces{foot}.experimentalGroundReactionForces(i, :) - ...
            modeledValues.(groundReactions(i)));
        title(groundReactions(i) + newline + " RMSE: " + error)
        xlabel('Time')
        hold off
    else
        plot(inputs.surfaces{foot}.time, ...
            inputs.surfaces{foot}.experimentalGroundReactionMoments(i - 3, :), ...
            "red", "LineWidth", 2)
        hold on
        plot(inputs.surfaces{foot}.time, modeledValues.(groundReactions(i)), ...
            "blue", "LineWidth", 2)
        error = rms(inputs.surfaces{foot}.experimentalGroundReactionMoments(i - 3, :) - ...
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
