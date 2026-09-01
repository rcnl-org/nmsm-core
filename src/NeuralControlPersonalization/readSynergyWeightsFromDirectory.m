% This function is part of the NMSM Pipeline, see file for full license.
%
% Reads a synergyWeights.sto file from the given directory (matching by
% filename, via parseTrialData), validates its muscle columns against
% inputs.muscleTendonColumnNames and its row count against the number of
% synergies configured in inputs.synergyGroups, and reorders columns to
% match inputs.muscleTendonColumnNames order. Shared by loadFixedSynergyWeights
% (data_directory) and the initial_guess_directory warm-start loader.
%
% (string, struct) -> (2D Array of number)
% Reads and validates a synergyWeights.sto file

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Xuanning Liu                                                 %
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

function weights = readSynergyWeightsFromDirectory(directory, inputs)
model = Model(inputs.modelFileName);
[data, columnNames] = parseTrialData(directory, "synergyWeights", model);
columnNames = string(columnNames);

missingMuscles = setdiff(inputs.muscleTendonColumnNames, columnNames);
if ~isempty(missingMuscles)
    throw(MException('', '%s', "synergyWeights.sto in " + directory + ...
        " is missing weights for muscle(s): " + ...
        strjoin(missingMuscles, ", ")))
end
extraMuscles = setdiff(columnNames, inputs.muscleTendonColumnNames);
if ~isempty(extraMuscles)
    throw(MException('', '%s', "synergyWeights.sto in " + directory + ...
        " contains unexpected muscle(s) not in this study's model: " + ...
        strjoin(extraMuscles, ", ")))
end
[~, reorderIndex] = ismember(inputs.muscleTendonColumnNames, columnNames);
weights = data(:, reorderIndex);

expectedNumSynergies = sum(cellfun(@(g) g.numSynergies, inputs.synergyGroups));
if size(weights, 1) ~= expectedNumSynergies
    throw(MException('', '%s', sprintf(...
        "synergyWeights.sto has %d synergies but %d are configured " + ...
        "in this settings file", size(weights, 1), expectedNumSynergies)))
end
end
