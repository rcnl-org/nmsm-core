% This function is part of the NMSM Pipeline, see file for full license.
%
% (struct) -> (struct)
% Prepares body orientations for cost and constraint terms.

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

function inputs = makeOrientationTracking(inputs)
names = string([]);
bodies = [];
inputs.calculateBodyOrientation = 0;
orientationCostTerms = [ ...
    "body_orientation_tracking", ...
    "body_orientation_minimization", ...
    ];
orientationConstraintTerms = [ ...
    "body_orientation_deviation", ...
    "body_orientation_value", ...
    "initial_body_orientation_deviation", ...
    "initial_body_orientation_value", ...
    "final_body_orientation_deviation", ...
    "final_body_orientation_value", ...
    "body_orientation_periodicity", ...
    ];
for i = 1:length(inputs.costTerms)
    costTerm = inputs.costTerms{i};
    if any(strcmp(costTerm.type, orientationCostTerms))
        names(end + 1) = convertCharsToStrings(inputs.model.getBodySet().get( ...
            costTerm.body).getName().toCharArray()');
        bodies(end + 1) = inputs.model.getBodySet().getIndex( ...
            costTerm.body);
    end
end
for i = 1:length(inputs.path)
    constraintTerm = inputs.path{i};
    if any(strcmp(constraintTerm.type, orientationConstraintTerms))
        names(end + 1) = convertCharsToStrings(inputs.model.getBodySet().get( ...
            constraintTerm.body).getName().toCharArray()');
        bodies(end + 1) = inputs.model.getBodySet().getIndex( ...
            constraintTerm.body);
    end
end
for i = 1:length(inputs.terminal)
    constraintTerm = inputs.terminal{i};
    if any(strcmp(constraintTerm.type, orientationConstraintTerms))
        names(end + 1) = convertCharsToStrings(inputs.model.getBodySet().get( ...
            constraintTerm.body).getName().toCharArray()');
        bodies(end + 1) = inputs.model.getBodySet().getIndex( ...
            constraintTerm.body);
    end
end

[inputs.trackedOrientationNames, indices] = unique(names);
inputs.trackedOrientationIndices = bodies(indices);
if ~isempty(inputs.trackedOrientationNames)
    inputs.calculateBodyOrientation = 1;
    appliedLoads = zeros(length(inputs.experimentalTime), ...
        inputs.model.getForceSet.getSize());
    [~, ~, ~, ~, bodyOrientations] = inverseDynamics( ...
        inputs.experimentalTime, inputs.experimentalJointAngles, ...
        inputs.experimentalJointVelocities, ...
        inputs.experimentalJointAccelerations, inputs.coordinateNames, ...
        appliedLoads, inputs.mexModel, [], ...
        inputs.trackedOrientationIndices, 0, 0, 1, inputs.osimVersion);
    inputs.splineBodyOrientationsLabels = ...
        repelem(inputs.trackedOrientationNames, 1, 3) + ...
        repmat(["_x" "_y" "_z"], 1, ...
        length(inputs.trackedOrientationNames));
    inputs.splineBodyOrientations = makeGcvSplineSet( ...
        inputs.experimentalTime, bodyOrientations, ...
        inputs.splineBodyOrientationsLabels);
    inputs.experimentalBodyOrientations = bodyOrientations;
end
end
