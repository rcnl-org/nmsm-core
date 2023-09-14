% This function is part of the NMSM Pipeline, see file for full license.
%
% This function calculates the joint velocities, accelerations, and jerk
% based of the experimental joint angles using 5th degree GCV splines.
%
% (struct) -> (struct)
% Returns state derivatives

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Marleny Vega, Spencer Williams, Claire V. Hammond            %
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

function inputs = makeStateDerivatives(inputs, params)
jointAnglesSpline = spaps(inputs.experimentalTime, ...
    inputs.experimentalJointAngles, eps, [], 3);
inputs.experimentalJointVelocities = fnval(fnder(jointAnglesSpline, 1), ...
    inputs.experimentalTime);
jointVelocitiesSpline = spaps(inputs.experimentalTime, ...
    inputs.experimentalJointVelocities, eps, [], 3);
inputs.experimentalJointAccelerations = fnval( ...
    fnder(jointVelocitiesSpline, 1), inputs.experimentalTime);
jointAccelerationsSpline = spaps(inputs.experimentalTime, ...
    inputs.experimentalJointAccelerations, eps, [], 3);
inputs.experimentalJointJerks = fnval(fnder(jointAccelerationsSpline, ...
    1), inputs.experimentalTime);

% points = length(inputs.experimentalTime);
% interval = inputs.experimentalTime(2) - inputs.experimentalTime(1);
% cutoffFrequency = ...
%     valueOrAlternate(params, "experimentalBSplineCutoffFrequency", 6);
% numNodes = splFitWithCutoff(inputs.experimentalTime', ...
%     inputs.experimentalJointAngles', cutoffFrequency, 5);
% [N, Np, Npp] = BSplineMatrices(5, numNodes, points, interval);
% Nodes = N\inputs.experimentalJointAngles;
% inputs.experimentalJointVelocities = Np * Nodes;
% inputs.experimentalJointAccelerations = Npp * Nodes;
% inputs.experimentalJointJerks = calcBSplineDerivative( ...
%     inputs.experimentalTime, inputs.experimentalJointAccelerations, ...
%     2, numNodes);
end
