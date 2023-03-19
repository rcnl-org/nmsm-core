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

% Make sure the nmsm-core project is open by double-clicking Project.prj in
% the nmsm-core repository.
settingsFileName = 'IsolatedReinboltKneeExample.xml';
settingsTree = xml2struct(settingsFileName);
[outputFile, inputs, params] = parseJointModelPersonalizationSettingsTree(settingsTree);
JointModelPersonalization(inputs, params);

jointArray = {"knee_l"};
markerFile = "l_knee.trc";

% calculate improvement in marker error for markers on distal and proximal
% bodies
start = sqrt(calculateJointError('Rajagopal_4.0_RCNL_markers_scaled.osim', ...
    1, jointArray, markerFile, 1e-6))

final = sqrt(calculateJointError('Rajagopal_4.0_RCNL_markers_scaled_knee.osim', ...
    1, jointArray, markerFile, 1e-6))

improvement = (final - start) / start

% use plotBeforeAndAfterMarkerError.m example to visualize difference
