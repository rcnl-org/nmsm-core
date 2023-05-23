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
% Author(s): Marleny Vega, Claire V. Hammond                              %
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

function integrand = calcDesignOptimizationIntegrand(values, auxdata)
integrand = [];
costTermType.coordinate_tracking = @(values, auxdata, costTerm) ...
    calcTrackingCoordinateIntegrand( ...
    auxdata, ...
    values.time, ...
    values.statePositions, ...
    costTerm.coordinate ...
    );
costTermType.controller_tracking = @(values, auxdata, costTerm) ...
    calcTrackingControllerIntegrand(auxdata, values, ...
    costTerm.controller);
costTermType.joint_jerk_minimization = @(values, auxdata, costTerm) ...
    calcMinimizingJointJerkIntegrand(values.controlJerks, ...
    auxdata, costTerm.coordinate);
costTermType.user_defined = @(values, auxdata, costTerm) ...
    userDefinedFunction(values, auxdata, costTerm);
for i = 1:length(auxdata.costTerms)
    costTerm = auxdata.costTerms{i};
    if costTerm.isEnabled
        if isfield(costTermType, costTerm.type)
            fn = costTermType.(costTerm.type);
            integrand = cat(2, integrand, fn(values, auxdata, costTerm));
        else
            throw(MException('', ['Cost term type ' costTerm.type ...
                ' does not exist for this tool.']))
        end
    end
end
integrand = scaleToBounds(integrand, auxdata.maxIntegral, auxdata.minIntegral);
integrand = integrand .^ 2;
end

function output = userDefinedFunction(values, auxdata, costTerm)
output = [];
if strcmp(costTerm.cost_term_type, 'continuous')
    output = costTerm.function_name(values, auxdata, costTerm);
end
end
