% This function is part of the NMSM Pipeline, see file for full license.
%
% This function cuts the data files into the sections outlined with the
% number of frames indicated
%
% Inputs -
%   prefix - string name of trial
%   fileName - string path of file
%   timePairs - 2D array of size N x 2
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

function sectionDataFiles(fileNames, timePairs, numRows, prefix)
import org.opensim.modeling.Storage
for i=1:length(fileNames)
    storage = Storage(fileNames(i));
    data = storageToDoubleMatrix(storage);
    time = findTimeColumn(storage);
    columnNames = getStorageColumnNames(storage);
    for j=1:size(timePairs, 1)
        [filepath, name, ext] = fileparts(fileNames(i));
        [newData, newTime] = cutData(data, time, timePairs(j,1), ...
            timePairs(j,2), numRows);
        newFileName = insertAfter(name, prefix, "_" + num2str(j));
        writeToSto(columnNames, newTime, newData', fullfile(filepath, ...
            newFileName + ext));
    end
end
end

function [newData, newTime] = cutData(data, time, startTime, endTime, ...
    numRows)
newTime = linspace(startTime, endTime, numRows);
newData = spline(time, data, newTime);
end

