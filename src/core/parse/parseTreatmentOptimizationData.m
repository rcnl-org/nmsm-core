% This function is part of the NMSM Pipeline, see file for full license.
%
% This function pulls the files from the directory given as the input. 
% These files are then organized into a 2D matrix with dimensions matching:
% (numFrames, numMuscles) and/or (numFrames, numCoordinates)
%
% (Array of string, Array of string, Model) -> (2D matrix, Cell)
% Returns a 2D matrix

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
% http://www.apache.org/licenses/LICENSE2.0.                             %
%                                                                         %
% Unless required by applicable law or agreed to in writing, software     %
% distributed under the License is distributed on an "AS IS" BASIS,       %
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or         %
% implied. See the License for the specific language governing            %
% permissions and limitations under the License.                          %
% ----------------------------------------------------------------------- %

function [data, dataLabels] = parseTreatmentOptimizationData(directory, ...
    prefix, model)
[data, dataLabels] = parseFileFromDirectories(directory, prefix, model);
newData = zeros(size(data, 2), size(data, 3));
newData(:, :) = data(1, :, :);
data = newData';
dataLabels = cellstr(dataLabels);
end