% This function is part of the NMSM Pipeline, see file for full license.
%
% (struct, Array of double, Array of string, Array of string) -> 
% (Array of number, struct)
%
% Finds data in an array given labels, saving an index for future calls.

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Spencer Williams                                             %
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

function [dataColumns, term] = findImuQuantitiesByLabels(term, imuQuantities, ...
    imuLabels, targetLabels, axes, isVelocity)
if isfield(term, 'internalImuIndices')
    indices = term.internalImuIndices;
else
    targetLabels = string(targetLabels);
    assert(length(targetLabels) == length(axes), "Number of IMU " + ...
        "quantities labels and axes to find must match.")
    indices = zeros(1, length(targetLabels));
    for i = 1 : length(targetLabels)
        imuBodyNumber = find(strcmp(imuLabels, targetLabels(i)));
        imuAxisNumber = find(strcmp(["x" "y" "z"], axes(i)));
        indices(i) = (imuBodyNumber - 1) * 6 + 3 * isVelocity ...
            + imuAxisNumber;
    end

    term.internalImuIndices = indices;
end
dataColumns = imuQuantities(:, indices);
end
