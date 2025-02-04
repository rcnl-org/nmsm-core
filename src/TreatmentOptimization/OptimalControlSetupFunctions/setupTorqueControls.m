% This function is part of the NMSM Pipeline, see file for full license.
%
% This function stores the initial control torques as a spline for use
% in cost terms for Treatment Optimization
%
% (string) -> (None)
% Spline input control torques

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

function inputs = setupTorqueControls(inputs)
if isfield(inputs, "torqueControllerCoordinateNames") && ...
        ~isempty(inputs.torqueControllerCoordinateNames)
if ~isfield(inputs, "initialTorqueControls")
    indices = find(ismember(erase(erase( ...
        inputs.initialInverseDynamicsMomentLabels, '_moment'), ...
        '_force'), inputs.torqueControllerCoordinateNames));
    inputs.initialTorqueControlsLabels = inputs.initialInverseDynamicsMomentLabels(indices);
    inputs.initialTorqueControls = inputs.initialJointMoments(:, indices);
end
inputs.splineTorqueControls = makeGcvSplineSet(inputs.initialTime, ...
    inputs.initialTorqueControls', inputs.initialTorqueControlsLabels);
inputs.torqueLabels = inputs.initialTorqueControlsLabels;
end
end