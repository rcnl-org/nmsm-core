% This function is part of the NMSM Pipeline, see file for full license.
%
% This function adjusts the max isometric force for the given muscle in
% both the OpenSim model and the auxiliary data. 
%
% (struct, struct) -> (struct)
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

function inputs = applyMaxIsometricForceParameter(inputs, values)

parameterSet = inputs.auxdata.userDefinedVariables;
inputs.auxdata.model = Model(inputs.auxdata.model);
counter = 1;
for i = 1:length(parameterSet)
    if strcmp(parameterSet{i}.type, 'max_isometric_force')
        adjustModelMaxIsometricForce(inputs.auxdata.model, ...
            parameterSet{i}.muscle, values.max_isometric_force(counter));
        inputs = adjustMaxIsometricForce(inputs, ...
            parameterSet{i}.muscle, values.max_isometric_force(counter));
        counter = counter + 1;
    end
end
end