% This function is part of the NMSM Pipeline, see file for full license.
%
% 
%
% (struct) -> (None)
% Optimize ground contact parameters according to Jackson et al. (2016)

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

function writeOptimizedGroundReactionsToSto(inputs, params, ...
    resultsDirectory, modelName)
columnLabels = ["Fx" "Fy" "Fz" "Mx" "My" "Mz" "ECx" "ECy" "ECz"];
for foot = 1:length(inputs.tasks)
    models.("model_" + foot) = Model(inputs.tasks{foot}.model);
end
for foot = 1:length(inputs.tasks)
    [modeledJointPositions, modeledJointVelocities] = ...
        calcGCPJointKinematics(inputs.tasks{foot} ...
        .experimentalJointPositions, inputs.tasks{foot} ...
        .jointKinematicsBSplines, inputs.tasks{foot}.bSplineCoefficients);
    modeledValues = calcGCPModeledValues(inputs, inputs, ...
        modeledJointPositions, modeledJointVelocities, params, ...
        length(params.tasks), foot, models);
    center = inputs.tasks{foot}.midfootSuperiorPosition;
    center(2, :) = inputs.restingSpringLength;
    data = [modeledValues.anteriorGrf' modeledValues.verticalGrf' ...
        modeledValues.lateralGrf' modeledValues.xGrfMoment' ...
        modeledValues.yGrfMoment' modeledValues.zGrfMoment' center'];
    writeToSto(columnLabels, inputs.tasks{foot}.time, data, ...
        fullfile(resultsDirectory, strcat(modelName, "_Foot_", ...
            num2str(foot), "_optimizedGroundReactions.sto")));
end
end

