% This function is part of the NMSM Pipeline, see file for full license.
%
% This function reads all .sto files in resultsDirectory and converts them
% to a 3D array. Dimensions 1 & 2 represent rows and columns from a single 
% file, and dimension 3 holds different files. Returns a row vector
% containing column headings read from the .sto file, and a 3D array
% containing data from all files in resultsDirectory.
%
% (string) -> (array), (array)
% Extracts data from .sto file.

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

function [columnNames, data] = extractMtpDataFromSto(resultsDirectory)
    import org.opensim.modeling.Storage
    if exist(resultsDirectory, "dir")
        dataDir = dir(resultsDirectory);
        dataFiles = {dataDir(3:end).name};
    else
        fprintf("%s not found\n", resultsDirectory);
        columnNames = [];
        data = [];
        return
    end
    data = cell(1, numel(dataFiles));
    for i = 1:numel(dataFiles)
        dataStorage = Storage(fullfile(resultsDirectory, dataFiles{i}));
        columnNames = getStorageColumnNames(dataStorage);
        data{i} = storageToDoubleMatrix(dataStorage)';
    end
    trialSize = size(data{1});
    numTrials = numel(data);
    data = reshape(cell2mat(data), trialSize(1), trialSize(2), numTrials);
end