% This function is part of the NMSM Pipeline, see file for full license.
%
% This function saves electrical center shifts applied to experimental
% ground reaction data. 
%
% (struct, string, string) -> (None)
% Write experimental ground reactions to an OpenSim Storage file.

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

function writeExperimentalGroundReactionsNewElectricalCenterToSto( ...
    inputs, resultsDirectory)
[~, name, ext] = fileparts(inputs.grfFileName);
outfile = strcat("updated_", name, ext);
outfileCoP = strcat("updated_", name, "_CoP", ext);

storage = org.opensim.modeling.Storage(inputs.grfFileName);
[columnNames, time, data] = parseMotToComponents( ...
    Model(inputs.bodyModel), storage);
dataCoP = zeros(size(data'));

for i = 1 : length(inputs.surfaces)
    % Electrical center shift
    index = find(columnNames == convertCharsToStrings( ...
        inputs.surfaces{i}.electricalCenterColumns(1, :)));
    data(index, :) = data(index, :) + ...
        inputs.surfaces{i}.electricalCenterShiftX;
    index = find(columnNames == convertCharsToStrings( ...
        inputs.surfaces{i}.electricalCenterColumns(2, :)));
    data(index, :) = data(index, :) + ...
        inputs.surfaces{i}.electricalCenterShiftY;
    index = find(columnNames == convertCharsToStrings( ...
        inputs.surfaces{i}.electricalCenterColumns(3, :)));
    data(index, :) = data(index, :) + ...
        inputs.surfaces{i}.electricalCenterShiftZ;
    % Force plate rotation
    forceIndices = [find(columnNames == convertCharsToStrings( ...
        inputs.surfaces{i}.forceColumns(1, :))), ...
        find(columnNames == convertCharsToStrings( ...
        inputs.surfaces{i}.forceColumns(2, :))), ...
        find(columnNames == convertCharsToStrings( ...
        inputs.surfaces{i}.forceColumns(3, :)))];
    momentIndices = [find(columnNames == convertCharsToStrings( ...
        inputs.surfaces{i}.momentColumns(1, :))), ...
        find(columnNames == convertCharsToStrings( ...
        inputs.surfaces{i}.momentColumns(2, :))), ...
        find(columnNames == convertCharsToStrings( ...
        inputs.surfaces{i}.momentColumns(3, :)))];
    [data(forceIndices, :), data(momentIndices, :)] = ...
        rotateGroundReactions(data(forceIndices, :), ...
        data(momentIndices, :), inputs.surfaces{i}.forcePlateRotation);
end
for i = 1 : (size(dataCoP, 2) / 9)
    dataCoP(:, (9 * (i - 1)) + (1:9)) = ...
        makeCoPData(data((9 * (i - 1)) + (1:9), :)');
end
if ~exist(fullfile(resultsDirectory, "GRFData"), "dir")
    mkdir(fullfile(resultsDirectory, "GRFData"))
end
writeToSto(columnNames, time, data', ...
    fullfile(resultsDirectory, "GRFData", outfile));
writeToSto(columnNames, time, dataCoP, ...
    fullfile(resultsDirectory, "GRFData", outfileCoP));
end
