% This function is part of the NMSM Pipeline, see file for full license.
%
% () -> ()
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

function cost = calcTrackingControllerIntegrand(auxdata, values, ...
    controllerName)

switch auxdata.controllerType
    case 'synergy_driven'
        indx = find(strcmp(convertCharsToStrings( ...
            auxdata.synergyLabels), controllerName));
        synergyActivations = fnval(auxdata.splineSynergyActivations, values.time)';
        cost = calcTrackingCostArrayTerm(synergyActivations, values.controlSynergyActivations, indx);
    case 'torque_driven'
        indx1 = find(strcmp(convertCharsToStrings( ...
            auxdata.inverseDynamicMomentLabels), controllerName));
        indx2 = find(strcmp(convertCharsToStrings( ...
            strcat(auxdata.controlTorqueNames, '_moment')), controllerName));
        experimentalJointMoments = fnval(auxdata.splineJointMoments, values.time)';
        cost = experimentalJointMoments(:, indx1) - values.controlTorques(:, indx2);
end