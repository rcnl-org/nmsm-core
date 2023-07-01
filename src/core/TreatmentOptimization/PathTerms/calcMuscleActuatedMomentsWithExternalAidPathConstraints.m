% This function is part of the NMSM Pipeline, see file for full license.
%
% This function calculates the difference between the inverse dynamic
% moments and the muscle produced moments with the aid of an external 
% torque controller for the specified coordinate. Applicable only if the
% model is synergy driven and if an external torque controller is present.
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

function pathTerm = ...
    calcMuscleActuatedMomentsWithExternalAidPathConstraints(params, ...
    modeledValues, externalControlTorques, coordinate)

indx1 = find(strcmp(convertCharsToStrings(params.inverseDynamicMomentLabels), ...
    [coordinate '_moment']));
indx2 = find(strcmp(params.surrogateModelCoordinateNames, ...
     coordinate));
indx3 = find(strcmp(params.externalControlTorqueNames, ...
     coordinate));

pathTerm = modeledValues.inverseDynamicMoments(:, indx1) - ...
    (modeledValues.muscleJointMoments(:, indx2) + ...
    externalControlTorques(:, indx3));
end