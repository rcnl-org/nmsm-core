% This function is part of the NMSM Pipeline, see file for full license.
%
% (struct, Array of double, Array of string, Array of string) -> 
% (Array of number, struct)
%
% Finds control in an array given labels, saving an index for future calls.

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

function [controls, term] = findControlsByLabels(term, inputs, ...
    values, time, targetLabels)
targetLabels = string(targetLabels);
numberOfTerms = length(targetLabels);
if isfield(term, 'internalTorqueControlIndices')
    userDefinedControlIndices = term.internalUserDefinedControlIndices;
    muscleControlIndices = term.internalMuscleControlIndices;
    synergyControlIndices = term.internalSynergyControlIndices;
    torqueControlIndices = term.internalTorqueControlIndices;
else
    userDefinedControlIndices = zeros(size(targetLabels));
    muscleControlIndices = zeros(size(targetLabels));
    synergyControlIndices = zeros(size(targetLabels));
    torqueControlIndices = zeros(size(targetLabels));
    torqueControlSplinedIndices = torqueControlIndices;
    for i = 1 : numberOfTerms
        if inputs.controllerTypes(4)
            userDefinedControlIndices(i) = findOptionalDataIndicesByLabels( ...
                inputs.userDefinedControlLabels, targetLabels(i));
        else
            userDefinedControlIndices(i) = -1;
        end
        if userDefinedControlIndices(i) == -1 && inputs.controllerTypes(3)
            muscleControlIndices(i) = findOptionalDataIndicesByLabels( ...
                inputs.individualMuscleNames, targetLabels(i));
        else
            muscleControlIndices(i) = -1;
        end
        if muscleControlIndices(i) == -1 && inputs.controllerTypes(2)
            synergyControlIndices(i) = findOptionalDataIndicesByLabels( ...
                inputs.synergyLabels, targetLabels(i));
        else
            synergyControlIndices(i) = -1;
        end
        if muscleControlIndices(i) == -1 && synergyControlIndices(i) == -1
            torqueControlIndices(i) = ...
                findCoordinateIndicesFromLoadNames( ...
                inputs.torqueControllerCoordinateNames, ...
                targetLabels(i));
            if isfield(inputs, "torqueLabels")
                torqueControlSplinedIndices(i) = ...
                    findCoordinateIndicesFromLoadNames( ...
                    inputs.torqueLabels, ...
                    targetLabels(i));
            end
        else
            torqueControlIndices(i) = -1;
            torqueControlSplinedIndices(i) = -1;
        end

        assert(muscleControlIndices(i) > 0 || ...
            synergyControlIndices(i) > 0 || ...
            torqueControlIndices(i) > 0, targetLabels(i) ...
            + " is not a control label");
    end
    term.internalUserDefinedControlIndices = userDefinedControlIndices;
    term.internalMuscleControlIndices = muscleControlIndices;
    term.internalSynergyControlIndices = synergyControlIndices;
    term.internalTorqueControlIndices = torqueControlIndices;
    term.internalSplinedTorqueControlIndices = torqueControlSplinedIndices;
end
controls = zeros(length(time), numberOfTerms);
for i = 1 : numberOfTerms
    if userDefinedControlIndices(i) > 0
        controls(:, i) = values.userDefinedControls(:, ...
            userDefinedControlIndices(i));
    elseif muscleControlIndices(i) > 0
        controls(:, i) = values.controlMuscleActivations(:, ...
            muscleControlIndices(i));
    elseif synergyControlIndices(i) > 0
        controls(:, i) = values.controlSynergyActivations(:, ...
            synergyControlIndices(i));
    elseif torqueControlIndices(i) > 0
        controls(:, i) = values.torqueControls(:, torqueControlIndices(i));
    end
end
end
