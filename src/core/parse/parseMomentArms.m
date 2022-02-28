% This function is part of the NMSM Pipeline, see file for full license.
%
% This function makes a list of subdirectories and finds the coordinates in
% the subdirectories to organize the files into a 4D data matrix with
% dimensions matching: (numFrames, numTrials, numMuscles, numJoints)
%
% (string) -> (4D matrix of number)
% returns a 4D matrix of the loaded moment arm trials

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

function output = parseMomentArms(directories, model)
import org.opensim.modeling.Storage
firstTrial = parseMuscleAnalysisCoordinates(directories(1), model);
cells = zeros([length(directories) size(firstTrial)]);
cells(1, :, :, :) = firstTrial;
for i=2:length(directories)
    cells(i, :, :, :) = parseMuscleAnalysisCoordinates(directories(i), ...
        model);
end
output = permute(cells, [4 1 3 2]);
end


function cells = parseMuscleAnalysisCoordinates(inputDirectory, model)
import org.opensim.modeling.Storage
coordFileNames = findMuscleAnalysisCoordinateFiles(inputDirectory, model);
firstFile = storageToDoubleMatrix(Storage(coordFileNames(1)));
cells = zeros([length(coordFileNames) size(firstFile)]);
cells(1, :, :) = firstFile;
for i=2:length(coordFileNames)
    cells(2, :, :) = storageToDoubleMatrix(Storage(coordFileNames(i)));
end
end

function names = findMuscleAnalysisCoordinateFiles(directory, model)
files = dir(directory);
names = string([]);
for i=0:model.getCoordinateSet().getSize()-1
    for j=1:length(files)
        if(contains(files(j).name, strcat("MomentArm_", ...
                model.getCoordinateSet().get(i).getName().toCharArray', ...
                ".sto")))
            names(end+1) = fullfile(directory, files(j).name);
        end
    end
end
end
