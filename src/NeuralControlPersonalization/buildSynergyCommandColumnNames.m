% This function is part of the NMSM Pipeline, see file for full license.
%
% Builds the synergy command column names used when writing/reading
% *_synergyCommands.sto files: "<muscleGroupName>_<i>" where i is the
% synergy's 1-based index within its own group, resetting per group.
% Column order matches inputs.synergyGroups order, and the row order of
% synergyWeights.sto / the 3rd dimension of synergyCommands.
%
% (struct) -> (Array of string)

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

function commandColumns = buildSynergyCommandColumnNames(inputs)
commandColumns = [];
for j = 1 : length(inputs.synergyGroups)
    for i = 1 : inputs.synergyGroups{j}.numSynergies
        commandColumns = [commandColumns ...
            convertCharsToStrings( ...
            inputs.synergyGroups{j}.muscleGroupName) + ...
            "_" + convertCharsToStrings(num2str(i))];
    end
end
end
