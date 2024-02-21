% This function is part of the NMSM Pipeline, see file for full license.
%
% This function calculates the difference between the inverse dynamic
% moments and the sum of the torque and synergy controller produced moments
% for the specified coordinate.
%
% (struct, struct, string) -> (number)
%

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Claire V. Hammond                                            %
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

function pathTerm = calcKineticPathConstraint(inputs, ...
    modeledValues, torqueControls, loadName)
inverseDynamicsIndex = find(strcmp(convertCharsToStrings(inputs.inverseDynamicsMomentLabels), ...
    loadName));
if strcmpi(inputs.controllerType, "synergy")
    synergyIndex = find(inputs.dofsActuatedIndex == inverseDynamicsIndex);
else
    synergyIndex = [];
end
torqueIndex = find(strcmp(strcat(inputs.torqueControllerCoordinateNames, ...
    '_moment'), loadName));
if isempty(torqueIndex)
   torqueIndex = find(strcmp(strcat(inputs.torqueControllerCoordinateNames, ...
    '_force'), loadName)); 
end
if isempty(synergyIndex)
    synergyLoad = 0;
else
    synergyLoad = modeledValues.muscleJointMoments(:, synergyIndex);
end
if isempty(torqueIndex)
    torqueLoad = 0;
else
    torqueLoad = torqueControls(:, torqueIndex);
end
if length(synergyLoad) == 1 && length(torqueLoad) == 1 && ...
        torqueLoad == 0 && synergyLoad == 0
    throw(MException('', "kinetic path constraint load is not a" + ...
        " synergy driven or torque driven coordinate"))
end
pathTerm = modeledValues.inverseDynamicsMoments(:, inverseDynamicsIndex) - ...
    (synergyLoad + torqueLoad);
end
