% This function is part of the NMSM Pipeline, see file for full license.
%
% This function calculates the path constraint for design optimization
%
% (struct, struct, struct) -> (2D matrix)
% Returns path constraint

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

function path = calcDesignOptimizationPathConstraint(values, modeledValues, ...
    params)
path = [];
for i = 1:length(params.path)
    constraintTerm = params.path{i};
    if constraintTerm.isEnabled
        switch constraintTerm.type
            case "root_segment_residual_load"
                path = cat(2, path, ...
                    calcRootSegmentResidualsPathConstraints(...
                    constraintTerm.load, ...
                    params.inverseDynamicMomentLabels, ...
                    modeledValues.inverseDynamicMoments));
            case "muscle_model_moment_consistency"
                path = cat(2, path, ...
                    calcMuscleActuatedMomentsPathConstraints(params, ...
                    modeledValues, constraintTerm.load));
            case "torque_model_moment_consistency"
                path = cat(2, path, ...
                    calcTorqueActuatedMomentsPathConstraints(params, ...
                    modeledValues, values.controlTorques, constraintTerm.load));   
            case "limit_muscle_activation"
                path = cat(2, path, ...
                    calcMuscleActivationsPathConstraint(params, ...
                    modeledValues, constraintTerm.muscle));
            case "limit_normalized_fiber_length"
                path = cat(2, path, ...
                    calcNormalizedFiberLengthPathConstraint(params, ...
                    modeledValues, constraintTerm.muscle));
            case "external_control_muscle_moment_consistency"
                path = cat(2, path, ...
                    calcMuscleActuatedMomentsWithExternalAidPathConstraints( ...
                    params, modeledValues, values.externalTorqueControls, ...
                    constraintTerm.coordinate));
            otherwise
                throw(MException('', ['Constraint term type ' ...
                    constraintTerm.type ' does not exist for this tool.']))    
        end
    end
end
path = scaleToBounds(path, params.maxPath, params.minPath);
end