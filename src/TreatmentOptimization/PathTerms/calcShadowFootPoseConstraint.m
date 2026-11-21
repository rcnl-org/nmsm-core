% This function is part of the NMSM Pipeline, see file for full license.
%
% This function calculates the difference between one shadow foot
% coordinate and the value that places the shadow foot in the same pose as
% the model's foot. The shadow_foot_pose term is split into one term per
% shadow foot coordinate in setupShadowFeet, so each term returns a single
% column. Rotation differences are wrapped to [-pi, pi].
%
% (struct, struct, struct, struct) -> (Array of number, struct)
% Calculates the shadow foot pose path constraint

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2026 Rice University and the Authors                      %
% Author(s): Robert Salati                                                %
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

function [pathTerm, constraintTerm] = calcShadowFootPoseConstraint( ...
    constraintTerm, values, modeledValues, inputs)
surface = constraintTerm.shadowSurfaceIndex;
component = constraintTerm.shadowComponentIndex;
shadowValue = values.positions(:, ...
    inputs.contactSurfaces{surface}.shadowCoordinateIndices(component));
target = modeledValues.shadowFootTargets{surface}(:, component);
pathTerm = shadowValue - target;
if component >= 2 && component <= 4
    pathTerm = atan2(sin(pathTerm), cos(pathTerm));
end
end
