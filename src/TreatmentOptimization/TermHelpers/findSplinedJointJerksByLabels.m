% This function is part of the NMSM Pipeline, see file for full license.
%
% (struct, Array of double, Array of string) -> (Array of number)
%
% Finds splined joint accelerations given labels, saving indices.

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

function experimentalJointJerks = ...
    findSplinedJointJerksByLabels(term, inputs, time)
indices = term.internalDataIndices;
if all(size(time) == size(inputs.collocationTimeOriginal)) && ...
        max(abs(time / time(end) - ...
        inputs.collocationTimeOriginal / ...
        inputs.collocationTimeOriginal(end))) < 1e-6
    experimentalJointJerks = ...
        inputs.splinedJointJerks(:, indices);
elseif all(size(time) == size(inputs.collocationTimeOriginalWithEnd)) &&...
        max(abs(time - inputs.collocationTimeOriginalWithEnd)) < 1e-6
    experimentalJointJerks = ...
        inputs.splinedJointJerks(:, indices);
    experimentalJointJerks(end + 1, :) = ...
        inputs.experimentalJointJerks(end, indices);
elseif length(time) == 2
    experimentalJointJerks = ...
        inputs.experimentalJointJerks([1 end], indices);
else
    experimentalJointJerks = evaluateGcvSplines( ...
        inputs.splineJointAngles, indices - 1, time, 3);
end
end
