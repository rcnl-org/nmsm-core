% This function is part of the NMSM Pipeline, see file for full license.
%
% (struct, Array of double, Array of string, Array of string) -> 
% (Array of number, struct)
%
% Finds marker velocity data in an array given labels.

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

function [dataColumns, term] = findMarkerVelocityDataByLabels(term, ...
    inputs, markerVelocities, time, targetLabels, targetAxes)
if isfield(term, 'internalMarkerNameIndices')
    markerNameIndices = term.internalMarkerNameIndices;
    markerAxesIndices = term.internalMarkerAxesIndices;
else
    targetLabels = string(targetLabels);
    numberOfTerms = length(targetLabels);
    markerNameIndices = zeros(1, numberOfTerms);
    markerAxesIndices = false(numberOfTerms, 3);
    for i = 1 : numberOfTerms
        for j = 1 : length(inputs.trackedMarkerNames)
            index = find(strcmp(convertCharsToStrings( ...
                inputs.trackedMarkerNames), ...
                targetLabels(i)), 1);
            if ~isempty(index)
                markerNameIndices = index;
                markerAxesIndices(i, :) = [ ...
                    contains(lower(targetAxes), "x"), ...
                    contains(lower(targetAxes), "y"), ...
                    contains(lower(targetAxes), "z")];
            end
        end

        assert(markerNameIndices(i) ~= 0, targetLabels(i) + ...
            " is not a marker name");
    end
    term.internalMarkerNameIndices = markerNameIndices;
    term.internalMarkerAxesIndices = markerAxesIndices;
end
dataColumns = zeros(length(time), sum(any(markerAxesIndices)), ...
    length(markerNameIndices));
includedAxes = find(any(markerAxesIndices, 1));
for i = 1 : length(markerNameIndices)
    for j = 1 : length(includedAxes)
        if markerAxesIndices(i, includedAxes(j))
            dataColumns(:, j, i) = markerVelocities(:, includedAxes(j), ...
                markerNameIndices(i));
        end
    end
end
end
