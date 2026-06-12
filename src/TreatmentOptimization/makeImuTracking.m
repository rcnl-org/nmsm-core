% This function is part of the NMSM Pipeline, see file for full license.
%
% This function parses the settings tree resulting from xml2struct from the
% settings XML file common to all treatment optimizatin modules (trackning,
% verification, and design optimization).
%
% (struct) -> (struct, struct)
% returns the input values for all treatment optimization modules

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

function inputs = makeImuTracking(inputs)
names = string([]);
locations = [];
bodies = [];
imuCostTerms = [ ...
    "imu_linear_acceleration_tracking", ...
    "imu_angular_velocity_tracking", ...
    ];
imuConstraintTerms = [ ...
    "imu_linear_acceleration_deviation", ...
    "imu_linear_acceleration_value", ...
    "imu_angular_velocity_deviation", ...
    "imu_angular_velocity_value", ...
    ];
for i = 1:length(inputs.costTerms)
    costTerm = inputs.costTerms{i};
    if costTerm.isEnabled && any(strcmp(costTerm.type, imuCostTerms))
        names(end + 1) = costTerm.imu_body;
        locations = cat(1, locations, costTerm.imu_measurement_point);
        bodies(end + 1) = inputs.model.getBodySet().getIndex( ...
            costTerm.imu_body);
    end
end
for i = 1:length(inputs.path)
    constraintTerm = inputs.path{i};
    if constraintTerm.isEnabled && any(strcmp(constraintTerm.type, imuConstraintTerms))
        names(end + 1) = constraintTerm.imu_body;
        locations = cat(1, locations, constraintTerm.imu_measurement_point);
        bodies(end + 1) = inputs.model.getBodySet().getIndex( ...
            constraintTerm.imu_body);
    end
end
for i = 1:length(inputs.terminal)
    constraintTerm = inputs.terminal{i};
    if constraintTerm.isEnabled && any(strcmp(constraintTerm.type, imuConstraintTerms))
        names(end + 1) = constraintTerm.imu_body;
        locations = cat(1, locations, constraintTerm.imu_measurement_point);
        bodies(end + 1) = inputs.model.getBodySet().getIndex( ...
            constraintTerm.imu_body);
    end
end

[inputs.trackedImuNames, indices] = unique(names);
inputs.trackedImuLocations = locations(indices, :);
inputs.trackedImuBodyIndices = bodies(indices);
if ~isempty(inputs.trackedImuNames)
    inputs.calculateImuQuantities = true;
    inputs.splineImuData = makeGcvSplineSet(inputs.experimentalTime, ...
        inputs.experimentalImuData, inputs.imuLabels);
else
    inputs.calculateImuQuantities = false;
end
end

