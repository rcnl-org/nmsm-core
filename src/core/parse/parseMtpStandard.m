% This function is part of the NMSM Pipeline, see file for full license.
%
% This function pulls the files from the directory given as the input
% starting with 1.sto, 2.sto and continuing to n.sto and stops when the
% file cannot be found in the directory. These files are then organized
% into a 3D matrix with dimensions matching: (numFrames, numTrials,
% numMuscles)
%
% (string) -> (3D matrix of number)
% returns a 3D matrix of the loaded data trials

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

function output = parseMtpStandard(inputDirectory)
import org.opensim.modeling.Storage
numTrials = findNumberFiles(inputDirectory);
cells = zeros([numTrials size(storageToDoubleMatrix(Storage(fullfile(inputDirectory, strcat(num2str(1),'.sto')))))]);
size(cells)
for i=1:numTrials
    cells(i, :, :) = storageToDoubleMatrix(Storage(fullfile(inputDirectory, strcat(num2str(i),'.sto'))));
end
end

