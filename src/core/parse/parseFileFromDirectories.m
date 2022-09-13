% This function is part of the NMSM Pipeline, see file for full license.
%
% This function looks in the given directory for all subdirectories and
% finds a file that ends in Length.sto to load into the 3D number matrix
% matching (numFrames, numTrials, numMuscles)
%
% (string) -> (3D matrix of number)
% returns a 3D matrix of the loaded muscle tendon length data

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

function cells = parseFileFromDirectories(directories, suffix)
import org.opensim.modeling.Storage
firstTrial = parseFileInDirectory(directories(1), suffix);
cells = zeros([length(directories) size(firstTrial)]);
cells(1, :, :) = firstTrial;
for i=2:length(directories)
    cells(i, :, :) = parseFileInDirectory(directories(i), suffix);
end
end

function data = parseFileInDirectory(inputDirectory, suffix)
import org.opensim.modeling.Storage
data = '';
files = findDirectoryFileNames(inputDirectory);
for i=1:length(files)
    if(contains(files(i), suffix))
        data = storageToDoubleMatrix(Storage(files(i)));
        break;
    end
end
if(strcmp(data, ''))
    throw(MException('',"Unable to find " + suffix + " data file in " + ...
    "directory " + strrep(inputDirectory, '\', '\\') + ...
    " with prefix matching the input directory"))
end
end
