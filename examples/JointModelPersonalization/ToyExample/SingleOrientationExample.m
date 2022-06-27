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

% model file path assumes nmsm-core project is open
inputs.model = 'simple_arm_oriented_away.osim';

% Joint parameters to optimize
task1.parameters = {
    %{jointName, isParent, isTranslation, paramNum}
    {'r_elbow', 1, 0, 0}, ... %Orientation of x in the parent frame
};
% Associated marker file for task 1
task1.markerFile = 'simple_arm.trc';
task1.initialValues=[0.5];
task1.lowerBounds=[-0.5];
task1.upperBounds=[1.5];
% Add task to cell array of tasks as part of the input struct
inputs.tasks{1} = task1;

% Add desired error
inputs.desiredError = 0.01;

params.accuracy = 1e-6; % accuracy of the Inverse Kinematics Solver
params.display = 'iter';

newModel = JointModelPersonalization(inputs, params);
assert(isa(newModel, 'org.opensim.modeling.Model'))

frameValue = getFrameParameterValue(newModel, 'r_elbow', 1, 0, 0);
assert(abs(frameValue)<0.0001)

newModel.print("orientation_result.osim")