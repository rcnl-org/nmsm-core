% This function is part of the NMSM Pipeline, see file for full license.
%
% 
%
% (struct, Array of string, struct, struct, double) -> 
% (Array of double, Array of double)
% Calculate a nonlinear constraint enforcing positive vertical GRF. 

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

function [c, ceq] = calcGroundContactPersonalizationNonlinearConstraint(...
    values, fieldNameOrder, inputs, params, task)
% OpenSim models are non-serializable objects, so they cannot normally be
% passed to a parallel pool. Using a persistent variable, the models are
% opened once per parallel worker and repeatedly accessed. 
persistent models;
for foot = 1:length(inputs.surfaces)
    if ~isfield(models, "model_" + foot)
        models.("model_" + foot) = Model(inputs.surfaces{foot}.model);
    end
end
valuesStruct = unpackValues(values, inputs, fieldNameOrder);
% If a design variable is not included, its static value from inputs is
% added to valuesStruct so it can be used to calculate cost if needed. 
if ~params.tasks{task}.designVariables(1)
        valuesStruct.springConstants = inputs.springConstants;
end
if ~params.tasks{task}.designVariables(2)
        valuesStruct.dampingFactor = inputs.dampingFactor;
end
if ~params.tasks{task}.designVariables(3)
        valuesStruct.dynamicFrictionCoefficient = ...
            inputs.dynamicFrictionCoefficient;
end
if ~params.tasks{task}.designVariables(4)
        valuesStruct.viscousFrictionCoefficient = ...
            inputs.viscousFrictionCoefficient;
end
if ~params.tasks{task}.designVariables(5)
        valuesStruct.restingSpringLength = ...
            inputs.restingSpringLength;
end
if ~params.tasks{task}.designVariables(6)
    for foot = 1:length(inputs.surfaces)
        field = "bSplineCoefficients" + foot;
        valuesStruct.(field) = inputs.surfaces{foot}.bSplineCoefficients;
    end
end
if ~params.tasks{task}.designVariables(7)
    for foot = 1:length(inputs.surfaces)
        field = "electricalCenterX" + foot;
        valuesStruct.(field) = ...
            inputs.surfaces{foot}.electricalCenterShiftX;
    end
end
if ~params.tasks{task}.designVariables(8)
    for foot = 1:length(inputs.surfaces)
        field = "electricalCenterY" + foot;
        valuesStruct.(field) = ...
            inputs.surfaces{foot}.electricalCenterShiftY;
    end
end
if ~params.tasks{task}.designVariables(9)
    for foot = 1:length(inputs.surfaces)
        field = "electricalCenterZ" + foot;
        valuesStruct.(field) = ...
            inputs.surfaces{foot}.electricalCenterShiftZ;
    end
end

params.tasks{task}.costTerms = {};

c = [];
ceq = [];
for foot = 1:length(inputs.surfaces)
    field = "bSplineCoefficients" + foot;
    valuesBSplineCoefficients = ...
        reshape(valuesStruct.(field), [], 7);
    [modeledJointPositions, modeledJointVelocities] = ...
        calcGCPJointKinematics(inputs.surfaces{foot} ...
        .experimentalJointPositions, inputs.surfaces{foot} ...
        .jointKinematicsBSplines, valuesBSplineCoefficients);
    modeledValues = calcGCPModeledValues(inputs, valuesStruct, ...
        modeledJointPositions, modeledJointVelocities, params, task, ...
        foot, models);

    c = [c -(modeledValues.verticalGrf + 1)];
end
end

% Reformats the values array of design variables to a simpler struct. 
function valuesStruct = unpackValues(values, inputs, fieldNameOrder)
valuesStruct = struct();
start = 1;
for i=1:length(fieldNameOrder)
    % Kinematics are specific to each foot, but other design variables are
    % shared. 
    if contains(fieldNameOrder(i), "bSplineCoefficients")
        foot = convertStringsToChars(fieldNameOrder(i));
        foot = str2double(foot(end));
        valuesStruct.(fieldNameOrder(i)) = values(start:start + ...
            numel(inputs.surfaces{foot}.bSplineCoefficients) - 1);
        start = start + numel(inputs.surfaces{foot}.bSplineCoefficients);
    elseif contains(fieldNameOrder(i), "electricalCenterX")
        valuesStruct.(fieldNameOrder(i)) = values(start);
        start = start + 1;
    elseif contains(fieldNameOrder(i), "electricalCenterY")
        valuesStruct.(fieldNameOrder(i)) = values(start);
        start = start + 1;
    elseif contains(fieldNameOrder(i), "electricalCenterZ")
        valuesStruct.(fieldNameOrder(i)) = values(start);
        start = start + 1;
    else
        valuesStruct.(fieldNameOrder(i)) = values(start:start + ...
            numel(inputs.(fieldNameOrder(i))) - 1);
        if fieldNameOrder(i) == "springConstants"
            valuesStruct.(fieldNameOrder(i)) = ...
                1000 * valuesStruct.(fieldNameOrder(i));
        end
        start = start + numel(inputs.(fieldNameOrder(i)));
    end
end
end
