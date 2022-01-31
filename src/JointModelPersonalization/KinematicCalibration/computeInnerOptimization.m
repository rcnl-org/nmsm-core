% This function is part of the NMSM Pipeline, see file for full license.
%
% This function computes the inner optimization as defined in the Joint
% Model Personalization module by preparing and running the IK algorithm
% and returning a model with the new values
%
% (Model, struct) -> (Model)
% Returns new model with inverse kinematic optimized marker positions

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

function error = computeInnerOptimization(values, functions, model, ...
    markerFileName, params)
model = Model(model);
for i = 1:length(values)
    functions{i}(values(i), model);
end
markersReference = makeJmpMarkerRef(model, markerFileName, params);
error = computeInnerOptimizationHeuristic(model, ...
    markersReference, params);
markersReference = libpointer;
java.lang.System.gc();
end



