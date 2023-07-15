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

function inputs = getStateDerivatives(inputs)
% Use 5th degree GCV splines to match OpenSim ID method in GUI tool
storage = org.opensim.modeling.Storage(inputs.kinematicsFile);
gcvSplineSet = org.opensim.modeling.GCVSplineSet(5, storage);
timeCol = findTimeColumn(storage);
velocity = zeros(length(timeCol), storage.getColumnLabels.getSize() - 1);
acceleration = velocity;
jerk = velocity;
for i = 0:gcvSplineSet.getSize()-1
    for j = 1:length(timeCol)
        velocity(j, i+1) = gcvSplineSet.evaluate(i, 1, timeCol(j));
        acceleration(j, i+1) = gcvSplineSet.evaluate(i, 2, timeCol(j));
        jerk(j, i+1) = gcvSplineSet.evaluate(i, 3, timeCol(j));
    end
end
inputs.experimentalJointVelocities = velocity;
inputs.experimentalJointAccelerations = acceleration;
inputs.experimentalJointJerks = jerk;
end
