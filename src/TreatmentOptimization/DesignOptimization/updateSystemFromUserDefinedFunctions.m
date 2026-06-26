% This function is part of the NMSM Pipeline, see file for full license.
% 
% This function updates the osim model if model specific parameters are
% optimized based on given model function.
% 
% (struct) -> (struct, struct)
% Updates osim model based on design variables and model function

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Claire V. Hammond, Marleny Vega                              %
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

function [inputs, values] = updateSystemFromUserDefinedFunctions(inputs, values)
if isfield(inputs, 'systemFns') && ...
        ~isempty(inputs.systemFns)
    for i = 1:length(inputs.systemFns)
        func = str2func(inputs.systemFns(i));
        [inputs, values] = func(inputs, values);
    end
end
end