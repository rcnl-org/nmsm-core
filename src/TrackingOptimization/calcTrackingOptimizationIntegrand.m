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

function integrand = calcTrackingOptimizationIntegrand(values, params, ...
    phaseout)
integrand = [];
for i = 1:length(params.costTerms)
    costTerm = params.costTerms{i};
    if costTerm.isEnabled
        switch costTerm.type
            case "coordinate_tracking"
                integrand = cat(2, integrand, ...
                    calcTrackingCoordinateIntegrand(params, ...
                    values.time, values.statePositions, ...
                    costTerm.coordinate));
            case "inverse_dynamics_load_tracking"
                integrand = cat(2, integrand, ...
                    calcTrackingInverseDynamicLoadsIntegrand(params, ...
                    values.time, phaseout.inverseDynamicMoments, ...
                    costTerm.load));
            case "external_force_tracking"
                integrand = cat(2, integrand, ...
                    calcTrackingExternalForcesIntegrand(params, ...
                    phaseout.groundReactionsLab.forces, values.time, ...
                    costTerm.force));
            case "external_moment_tracking"
                integrand = cat(2, integrand, ...
                    calcTrackingExternalMomentsIntegrand(params, ...
                    phaseout.groundReactionsLab.moments, values.time, ...
                    costTerm.moment));
            case "muscle_activation"
                integrand = cat(2, integrand, ...
                    calcTrackingMuscleActivationIntegrand( ...
                    phaseout.muscleActivations, ...
                    values.time, params, costTerm.muscle));   
            case "joint_jerk_minimization"
                integrand = cat(2, integrand, ...
                    calcMinimizingJointJerkIntegrand(values.controlJerks, ...
                    params, costTerm.coordinate));
            otherwise
                throw(MException('', ['Cost term type ' costTerm.type ...
                    ' does not exist for this tool.']))    
        end
    end
end
integrand = integrand ./ (params.maxIntegral - params.minIntegral);
integrand = integrand .^ 2;
end