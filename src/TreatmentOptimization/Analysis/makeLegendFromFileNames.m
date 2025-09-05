% This function is part of the NMSM Pipeline, see file for full license.
%
% For plotting functions only
% Creates strings for legends using the given filepath. It chooses the
% legend label for each series of data to be the directory one level down
% from the top. In most cases this should be the results directory or
% tracked quantities directory.

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Robert Salati                                                %
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

function legendString = makeLegendFromFileNames(trackedDataFile, resultsDataFiles)
[directory, fileName, ~] = fileparts(trackedDataFile);
directoryFolderNames = split(directory, ["/", "\"]);
topFolderName = directoryFolderNames(end);
if any(strcmp(topFolderName, ["GRFData", "IDData", "IKData", "EMGData"]))
    topFolderName = directoryFolderNames(end-1);
end
legendString = sprintf("%s (T)", topFolderName);
% Logic to change the legend if using the replaced experimental ground
% reactions file because in that case, the legend labels will be the same
% for both lines.
if contains(fileName, "replacedExperimentalGroundReactions")
    legendString = sprintf("%s (T)", fileName);
end
for j = 1 : numel(resultsDataFiles)
    [directory, ~, ~] = fileparts(resultsDataFiles(j));
    directoryFolderNames = split(directory, ["/", "\"]);
    topFolderName = directoryFolderNames(end);
    if any(strcmp(topFolderName, ["GRFData", "IDData", "IKData", "EMGData"]))
        topFolderName = directoryFolderNames(end-1);
    end
    legendString(j+1) = sprintf("%s (%d)", topFolderName, j);
end
end

