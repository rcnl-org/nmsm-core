% This function is part of the NMSM Pipeline, see file for full license.
%
% (struct, struct, Array of number, Array of string) -> (Array of number)
% Tracks initial body angular velocities.

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Spencer Williams                                             %
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

function [pathTerm, constraintTerm] = ...
    calcFinalBodyAngularVelocityValue( ...
    constraintTerm, inputs, time, bodyAngularVelocities)
[angles, constraintTerm] = findBodyAxesByLabels(constraintTerm, ...
    bodyAngularVelocities, inputs.splineBodyAngularVelocitiesLabels, ...
    getTermFieldOrError(constraintTerm, 'body'), ...
    getTermFieldOrError(constraintTerm, 'axes'));

angles = findAngleInSequence(angles, constraintTerm);
pathTerm = angles(end);
end
