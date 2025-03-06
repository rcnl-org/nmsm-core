% This function is part of the NMSM Pipeline, see file for full license.
%
% (struct, Array of double, Array of string, Array of string) -> 
% (Array of number, struct)
%
% Finds splined control given labels, saving indices for future calls.

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

function controls = findSplinedControlsByLabels(term, inputs, time)
synergyControlIndices = term.internalSynergyControlIndices;
torqueControlIndices = term.internalSplinedTorqueControlIndices;
numberOfTerms = length(synergyControlIndices);

controls = zeros(length(time), numberOfTerms);
for i = 1 : numberOfTerms
    if synergyControlIndices(i) > 0
        if all(size(time) == size(inputs.collocationTimeOriginal)) && ...
                max(abs(time - inputs.collocationTimeOriginal)) < 1e-6
            controls(:, i) = inputs.splinedSynergyActivations(:, ...
                synergyControlIndices(i));
        else
            controls(:, i) = evaluateGcvSplines( ...
                inputs.splineSynergyActivations, ...
                synergyControlIndices(i) - 1, time);
        end
    elseif torqueControlIndices(i) > 0
        if all(size(time) == size(inputs.collocationTimeOriginal)) && ...
                max(abs(time - inputs.collocationTimeOriginal)) < 1e-6
            controls(:, i) = inputs.splinedTorqueControls(:, ...
                torqueControlIndices(i));
        else
            controls(:, i) = evaluateGcvSplines( ...
                inputs.splineTorqueControls, ...
                torqueControlIndices(i) - 1, time);
        end
    end
end
end
