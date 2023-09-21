% This function is part of the NMSM Pipeline, see file for full license.
%
% This function checks that the initial guess control file is in the
% correct order
%
% (struct) -> (struct)
%

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Marleny Vega                                                 %
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

function inputs = checkControlGuess(inputs)
if isfield(inputs.initialGuess, 'control')
    newControls = zeros(size(inputs.initialGuess.control, 1), 0);
    newLabels = string([]);
    for i = 1 : length(inputs.coordinateNames)
        index = find(ismember(inputs.initialGuess.controlLabels, inputs.coordinateNames(i)));
        if isempty(index)
            newControls(:, end + 1) = zeros(size(inputs.initialGuess.control, 1), 1);
        else
            newControls(:, end + 1) = inputs.initialGuess.control(:, index);
        end
        newLabels(end + 1) = inputs.coordinateNames(i);
    end
    if strcmp(inputs.controllerType, "synergy")
        for i = 1 : length(inputs.osimx.synergyGroups)
            for j = 1 : inputs.osimx.synergyGroups{i}.numSynergies
                index = find(ismember(inputs.initialGuess.controlLabels, ...
                    strcat(inputs.osimx.synergyGroups{i}.muscleGroupName, "_", num2str(j))));
                if isempty(index)
                    throw(MException("ParseError:SynergyCommands", ...
                        strcat("All synergy commands are required: ", ...
                        strcat(inputs.osimx.synergyGroups{i}.muscleGroupName, "_", num2str(j)))));
                else
                    newControls(:, end + 1) = inputs.initialGuess.control(:, index);
                end
                newLabels(end + 1) = strcat(inputs.osimx.synergyGroups{i}.muscleGroupName, "_", num2str(j));
            end
        end
    end
    inputs.initialGuess.control = newControls;
    inputs.initialGuess.controlLabels = newLabels;
end
end