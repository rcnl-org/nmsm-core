% This function is part of the NMSM Pipeline, see file for full license.
%
% (struct, Array of double, Array of string) -> (Array of number)
%
% Finds splined center of pressure component given labels.

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

function centerOfPressure = findSplinedCenterOfPressureByLabels(term, ...
    inputs, time)
contactSurfaceIndices = term.internalContactSurfaceIndices;
axes = getTermFieldOrError(term, 'axes');
axesIndex = find(axes == 'xz', 1);
if all(size(time) == size(inputs.collocationTimeOriginal)) && ...
        max(abs(time / time(end) - ...
        inputs.collocationTimeOriginal / ...
        inputs.collocationTimeOriginal(end))) < 1e-6
    centerOfPressureComponents = ...
        inputs.splinedCenterOfPressure{contactSurfaceIndices};
    centerOfPressure = centerOfPressureComponents(:, axesIndex);
elseif length(time) == 2
    centerOfPressureComponents = ...
        inputs.contactSurfaces{ ...
        contactSurfaceIndices}.experimentalCenterOfPressure;
    centerOfPressure = centerOfPressureComponents([1 end], axesIndex);
else
    centerOfPressure = evaluateGcvSplines( ...
        inputs.splineCenterOfPressure{contactSurfaceIndices}, axesIndex - 1, time);
end
end
