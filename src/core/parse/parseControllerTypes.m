% This function is part of the NMSM Pipeline, see file for full license.
%
% There are multiple controllers that can be used to solve optimal control
% problems in the NMSM Pipeline. This function finds the correct element to
% determine which controllers are being used. This informs the XML parsing
% logic.
%
% (struct) -> (string)
% returns logical vector depending on the settings file

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Claire V. Hammond, Spencer Williams                          %
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

function controllerTypes = parseControllerTypes(tree)
torque = getFieldByName(tree, 'RCNLTorqueController');
synergy = getFieldByName(tree, 'RCNLSynergyController');
muscle = getFieldByName(tree, 'RCNLMuscleController');
controllerTypes = [isstruct(torque), isstruct(synergy), isstruct(muscle)];
if all(~controllerTypes)
    throw(MException("ParseTreatmentOptimization:NoController", ...
       "Could not find <RCNLTorqueController>, " + ...
       "<RCNLSynergyController>, or <RCNLMuscleController>"))
end
end