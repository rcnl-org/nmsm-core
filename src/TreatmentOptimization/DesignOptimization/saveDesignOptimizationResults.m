% This function is part of the NMSM Pipeline, see file for full license.
%
% This function saves and prints the unscaled results from 
% Design Optimization. An osim model may also be printed if model specific
% values were optimized
%
% (struct, struct) -> (None)
% Prints design optimization results

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

function saveDesignOptimizationResults(solution, inputs)
values = makeGpopsValuesAsStruct(solution.solution.phase, inputs);
saveTreatmentOptimizationResults(solution, inputs, values)
if isfield(inputs, "systemFns")
    inputs.auxdata = inputs;
    inputs = updateSystemFromUserDefinedFunctions(inputs, values);
    model = Model(inputs.auxdata.model);
    model.print(strrep(inputs.mexModel, '_inactiveMuscles.osim', 'DesignOpt.osim'));
end
end