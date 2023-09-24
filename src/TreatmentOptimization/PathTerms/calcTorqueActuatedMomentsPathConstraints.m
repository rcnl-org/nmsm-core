% This function is part of the NMSM Pipeline, see file for full license.
%
% This function calculates the difference between the inverse dynamic
% moments and the torque based control for the specified coordinate.
% Applicable only if the model is torque driven.
%
% (struct, struct, 2D matrix, Array of string) -> (Array of number)
%

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
% http://www.apache.org/licenses/LICENSE-2.0.                             %
%                                                                         %
% Unless required by applicable law or agreed to in writing, software     %
% distributed under the License is distributed on an "AS IS" BASIS,       %
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or         %
% implied. See the License for the specific language governing            %
% permissions and limitations under the License.                          %
% ----------------------------------------------------------------------- %

function pathTerm = calcTorqueActuatedMomentsPathConstraints(inputs, ...
    modeledValues, controlTorques, loadName)

loadName = erase(loadName, '_moment');
loadName = erase(loadName, '_force');
indx1 = find(cellfun(@isequal, inputs.coordinateNames, ...
    repmat({loadName}, 1, length(inputs.coordinateNames))));
indx2 = find(strcmp(inputs.torqueControllerCoordinateNames, loadName));
pathTerm = modeledValues.inverseDynamicsMoments(:, indx1) - ...
    controlTorques(:, indx2);
end
