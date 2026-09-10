% This function is part of the NMSM Pipeline, see file for full license.
%
% (struct, Array of double, Array of string, Array of string) -> 
% (Array of number, struct)
%
% Finds ground reaction data in a cell array given labels.

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

function [dataColumns, term] = findGroundReactionMomentDataByLabels( ...
    term, inputs, groundReactions, time, targetLabels)
if isfield(term, 'internalGroundReactionIndices')
    groundReactionIndices = term.internalGroundReactionIndices;
    contactSurfaceIndices = term.internalContactSurfaceIndices;
else
    targetLabels = string(targetLabels);
    numberOfTerms = length(targetLabels);
    groundReactionIndices = zeros(1, numberOfTerms);
    contactSurfaceIndices = groundReactionIndices;
    for i = 1 : numberOfTerms
        for j = 1 : length(inputs.contactSurfaces)
            index = find(strcmp(convertCharsToStrings( ...
                inputs.contactSurfaces{j}.momentColumns), ...
                targetLabels(i)), 1);
            if ~isempty(index)
                groundReactionIndices = index;
                contactSurfaceIndices(i) = j;
            end
        end

        assert(groundReactionIndices(i) ~= 0, targetLabels(i) + ...
            " is not a ground reaction moment column name");
    end
    term.internalGroundReactionIndices = groundReactionIndices;
    term.internalContactSurfaceIndices = contactSurfaceIndices;
end
dataColumns = zeros(length(time), length(groundReactionIndices));
for i = 1 : length(groundReactionIndices)
    currentReactions = groundReactions{contactSurfaceIndices(i)};
    dataColumns(:, i) = currentReactions(:, groundReactionIndices(i));
end
end
