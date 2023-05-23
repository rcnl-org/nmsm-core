% This function is part of the NMSM Pipeline, see file for full license.
%
% This function returns all of the cost term calculation methods including
% user_defined and existing cost term values. Tools use this function for
% the discrete and continuous cost calculations.
%
% inputs:
% costTermType - one of ["discrete", "continuous"]
% toolName - one of ["TrackingOptimization", "TreatmentOptimization", ...
%   "DesignOptimization"]
%
% (string, string) -> (struct of function handles, Array of string)
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

function [costTermCalculations, allowedTypes] = ...
    generateCostTermStruct(costTermType, toolName)
allowedTypes = getAllowedTypes(costTermType, toolName);
costTermCalculations = getCostTermCalculations(costTermType);
end

function allowedTypes = getAllowedTypes(costTermType, toolName)
if strcmp(costTermType, "continuous")
    switch toolName
        case "TrackingOptimization"
            allowedTypes = [ ...

            ];
        case "VerificationOptimization"
            allowedTypes = [ ...

            ];
        case "DesignOptimization"
            allowedTypes = [ ...
                "coordinate_tracking", ...
                "controller_tracking", ...
                "joint_jerk_minimization", ...
                "user_defined", ...
                ];
        otherwise
            throw(MException('', ['Tool name' toolName 'is not valid']))
    end
elseif strcmp(costTermType, "discrete")
    switch toolName
        case "TrackingOptimization"
            allowedTypes = [ ...

            ];
        case "VerificationOptimization"
            allowedTypes = [ ...

            ];
        case "DesignOptimization"
            allowedTypes = [ ...

            ];
        otherwise
            throw(MException('', ['Tool name' toolName 'is not valid']))
    end
else
    throw(MException('', ['Cost term type ' costTermType ...
        ' is not valid, must be continuous or discrete']))
end
end

function costTermCalculations = getCostTermCalculations(costTermType)

costTermCalculations.coordinate_tracking = @(values, modeledValues, auxdata, costTerm) ...
    calcTrackingCoordinateIntegrand( ...
    auxdata, ...
    values.time, ...
    values.statePositions, ...
    costTerm.coordinate ...
    );

costTermCalculations.controller_tracking = @(values, modeledValues, auxdata, costTerm) ...
    calcTrackingControllerIntegrand( ...
    auxdata, ...
    values, ...
    costTerm.controller ...
    );

costTermCalculations.joint_jerk_minimization = @(values, modeledValues, auxdata, costTerm) ...
    calcMinimizingJointJerkIntegrand( ...
    values.controlJerks, ...
    auxdata, ...
    costTerm.coordinate ...
    );

costTermCalculations.metabolic_cost = @(values, modeledValues, auxdata, costTerm) ...
    calcMinimizingMetabolicCost(modeledValues.metabolicCost);

costTermCalculations.user_defined = @(values, modeledValues, auxdata, costTerm) ...
    userDefinedFunction(values, modeledValues, auxdata, costTerm, costTermType);

end

function output =  ...
    userDefinedFunction(values, modeledValues, auxdata, costTerm, costTermType)
output = [];
if strcmp(costTerm.cost_term_type, costTermType)
    output = costTerm.function_name(values, modeledValues, auxdata, costTerm);
end
end
