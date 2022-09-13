% This function is part of the NMSM Pipeline, see file for full license.
%
% This function pulls the files from the directory given as the input. 
% These files time columns are then organized into a 2D matrix with
% dimensions matching: (numFrames, numTrials)
%
% (Array of string) -> (2D matrix of number)
% returns a 2D matrix of the trial time columns

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

function cells = parseTimeColumn(files)
import org.opensim.modeling.Storage
dataFromFileOne = findTimeColumn(Storage(files(1)));
cells = zeros(length(files), length(dataFromFileOne));
cells(1, :) = dataFromFileOne;
for i=2:length(files)
    cells(i, :) = findTimeColumn(Storage(files(i)));
end
end