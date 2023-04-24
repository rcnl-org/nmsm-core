% This function is part of the NMSM Pipeline, see file for full license.
%
% () -> ()
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

function cells = parseSelectMomentArms(directories, coordinateNames, muscleNames)
import org.opensim.modeling.Storage
firstTrial = parseSpecificMuscleAnalysisCoordinates(directories(1), ...
    coordinateNames, muscleNames);
cells = zeros([length(directories) size(firstTrial)]);
cells(1, :, :, :) = firstTrial;
for i=2:length(directories)
    cells(i, :, :, :) = parseSpecificMuscleAnalysisCoordinates(directories(i), ...
        coordinateNames, muscleNames);
end
end

function cells = parseSpecificMuscleAnalysisCoordinates(inputDirectory, ...
    coordinateNames, muscleNames)
import org.opensim.modeling.Storage
coordFileNames = findSpecificMuscleAnalysisCoordinateFiles(inputDirectory, coordinateNames);
firstFile = storageToDoubleMatrix(Storage(coordFileNames(1)));
columnNames = getStorageColumnNames(Storage(coordFileNames(1)));
cells = zeros([length(coordFileNames) size(firstFile)]);
cells(1, :, :) = firstFile;
for i=2:length(coordFileNames)
    cells(i, :, :) = storageToDoubleMatrix(Storage(coordFileNames(i)));
end
cells = findSpecificMusclesInData(cells, columnNames, muscleNames);
end

function names = findSpecificMuscleAnalysisCoordinateFiles(directory, coordinateNames)
files = dir(directory);
names = string([]);
for i=1:length(coordinateNames)
    for j=1:length(files)
        if(contains(files(j).name, strcat("MomentArm_", ...
                coordinateNames(i)', ".sto")))
            names(end+1) = fullfile(directory, files(j).name);
        end
    end
end
end