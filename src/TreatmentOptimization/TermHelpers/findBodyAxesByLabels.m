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

function [dataColumns, term] = findBodyAxesByLabels(term, data, ...
    dataLabels, targetLabels, axes)
if isfield(term, 'internalBodyAxesIndices')
    indices = term.internalBodyAxesIndices;
else
    targetLabels = string(targetLabels);
    if isfield(term, 'sequence')
        axes = 'xyz';
    end
    axes = split(lower(erase(axes, ' ')), '', 2);
    axes = "_" + axes(2:end-1);
    fullLabels = repelem(targetLabels, 1, length(axes)) + ...
        repmat(axes, 1, length(targetLabels));
    indices = findDataIndicesByLabels(dataLabels, fullLabels);
    term.internalBodyAxesIndices = indices;
end
dataColumns = data(:, indices);
end
