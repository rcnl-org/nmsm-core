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

function expandEmgDatas(modelFileName, inputDirectory, outputDirectory, ...
    expandedFileName)
import org.opensim.modeling.Storage
emgFileNames = findDirectoryFileNames(inputDirectory);
expandedData = Storage(expandedFileName); % load ref columns
emgData = Storage(emgFileNames(1)); % first emg data for making nameToGroup
model = Model(modelFileName);
nameToGroup = getMuscleNameToGroupStruct(model, ...
    getStorageColumnNames(emgData), getStorageColumnNames(expandedData));
%iterate through and save output to directory
i = 1; % while loop because first file was already loaded
while i <= length(emgFileNames)
    expandEmgData(expandedData, emgData, nameToGroup)
    [~, name, ext] = fileparts(emgFileNames(i));
    expandedData.print(fullfile(outputDirectory, ...
        name + "_expanded" + ext));
    i = i + 1;
    if(i<=length(emgFileNames)); emgData = Storage(emgFileNames(i)); end
end 
end

% (Model, Array of string) -> (struct)
% Get name to group relationship struct from model and group names
function nameToGroup = getMuscleNameToGroupStruct(model, emgDataNames, ...
    muscleAnalysisNames)
for i=1:length(emgDataNames) % struct group names with muscle names inside
    groupSize = model.getForceSet().getGroup(emgDataNames(i)) ...
        .getMembers().size();
    groupToName.(emgDataNames(i)) = string(zeros(1,groupSize));
    for j=0:groupSize-1
        groupToName.(emgDataNames(i))(j+1) = model.getForceSet() ...
            .getGroup(emgDataNames(i)).getMembers().get(j).getName() ...
            .toCharArray';
    end
end
for i=1:length(muscleAnalysisNames) % reverse direction - muscle names to
    for j=1:length(emgDataNames)    % group name
        if(~isempty(find(strcmp(muscleAnalysisNames(i), groupToName ...
                .(emgDataNames(j))), 1)))
            nameToGroup.(muscleAnalysisNames(i)) = emgDataNames(j);
        end
    end
end
end

function expandEmgData(expandedData, emgData, nameToGroup)
import org.opensim.modeling.ArrayDouble
expandedData.scaleTime((emgData.getLastTime() - ... %scale time
    emgData.getFirstTime()) / (expandedData.getLastTime() - ...
    expandedData.getFirstTime())); %shift time
expandedData.shiftTime(emgData.getFirstTime()-expandedData.getFirstTime());
expandedColumnNames = getStorageColumnNames(expandedData);
for j=1:length(expandedColumnNames)
    arrayDouble = ArrayDouble();
    emgData.getDataColumn(nameToGroup.(expandedColumnNames(j)), arrayDouble);
    temp = changeNumEmgPoints(arrayDoubleToDoubleArray(arrayDouble), ...
        emgData.getFirstTime(), emgData.getLastTime(), ...
        expandedData.getSize());
    expandedData.setDataColumn(j-1, numberArrayToArrayDouble(temp));
end
end
