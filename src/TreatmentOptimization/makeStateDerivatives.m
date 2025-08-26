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
inputs.splineJointAngles = makeGcvSplineSet(inputs.experimentalTime, ...
    inputs.experimentalJointAngles', inputs.coordinateNames);
inputs.experimentalJointVelocities = evaluateGcvSplines( ...
    inputs.splineJointAngles, inputs.coordinateNames, ...
    inputs.experimentalTime, 1);
inputs.experimentalJointAccelerations = evaluateGcvSplines( ...
    inputs.splineJointAngles, inputs.coordinateNames, ...
    inputs.experimentalTime, 2);
if inputs.useJerk
    inputs.experimentalJointJerks = evaluateGcvSplines( ...
        inputs.splineJointAngles, inputs.coordinateNames, ...
        inputs.experimentalTime, 3);
end
splineInitialJointAngles = makeGcvSplineSet(inputs.initialTime, ...
    inputs.initialJointAngles', inputs.initialCoordinateNames);
if strcmp(inputs.solverType, 'gpops')
    inputs.initialJointVelocities = evaluateGcvSplines( ...
        splineInitialJointAngles, inputs.initialCoordinateNames, ...
        inputs.initialTime, 1);
    inputs.initialJointAccelerations = evaluateGcvSplines( ...
        splineInitialJointAngles, inputs.initialCoordinateNames, ...
        inputs.initialTime, 2);
    if inputs.useJerk
        inputs.initialJointJerks = evaluateGcvSplines( ...
            splineInitialJointAngles, inputs.initialCoordinateNames, ...
            inputs.initialTime, 3);
    end
else
    inputs.initialJointAngles = evaluateGcvSplines( ...
        splineInitialJointAngles, inputs.initialCoordinateNames, ...
        inputs.collocationTimeOriginalWithEnd);
    inputs.initialJointVelocities = evaluateGcvSplines( ...
        splineInitialJointAngles, inputs.initialCoordinateNames, ...
        inputs.collocationTimeOriginalWithEnd, 1);
    inputs.initialJointAccelerations = evaluateGcvSplines( ...
        splineInitialJointAngles, inputs.initialCoordinateNames, ...
        inputs.collocationTimeOriginalWithEnd, 2);
    if inputs.useJerk
        inputs.initialJointJerks = evaluateGcvSplines( ...
            splineInitialJointAngles, inputs.initialCoordinateNames, ...
            inputs.collocationTimeOriginalWithEnd, 3);
    end
end
end
