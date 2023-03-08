% This function is part of the NMSM Pipeline, see file for full license.
%
% This function expands the given EMG .sto files to match the names and
% number of columns of a given muscle analysis file for use in the
% MuscleTendonPersonalizationTool.
%
% expandedFileName is the name of the file to match column names and muscle
% groups from. It is generally a Muscle Analysis file.
%
% (string, string, string, string) -> (None)
% Makes new EMG data files with columns matching the file given

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Claire V. Hammond                                            %
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

function newEmgData = expandEmgDatas(model, emgData, groupColumnNames, ...
    muscleNames)
model = Model(model);
groupToName = getMuscleNameByGroupStruct(model, groupColumnNames);
newEmgData = expandEmgData(muscleNames, emgData, ...
    groupToName, groupColumnNames);
end

function newEmgData = expandEmgData(expandedColumnNames, emgData, ...
    namesByGroup, emgColumnNames)
newEmgData = zeros(length(expandedColumnNames), size(emgData, 2));
for i=1:length(emgColumnNames)
    musclesInGroup = namesByGroup.(emgColumnNames(i));
    temp = emgData(i, :);
    for j=1:length(musclesInGroup)
        test = newEmgData(ismember(expandedColumnNames, ...
            musclesInGroup(j)), :);
        newEmgData(ismember(expandedColumnNames, ...
            musclesInGroup(j)), :) = temp;
    end
end
end
