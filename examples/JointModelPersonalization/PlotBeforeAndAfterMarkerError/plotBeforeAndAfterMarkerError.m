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

% List markers of interest. for this example, it is the markers about the
% knee joint.
markerNames = ["L.Thigh.Superior", "L.Thigh.Inferior", ...
    "L.Thigh.Lateral", "L.Shank.Superior", "L.Shank.Inferior", ...
    "L.Shank.Lateral"];

% Generate the .sto file for the marker error values for the original
% model.
reportDistanceErrorByMarker('Rajagopal_4.0_RCNL_markers_scaled.osim', ...
    'l_knee.trc', markerNames, 'start.sto')

% Generate the .sto file for the marker error values after JMP. In this
% case, the knee isolated trial was used to optimize the knee parameters.
reportDistanceErrorByMarker( ...
    'Rajagopal_4.0_RCNL_markers_scaled_knee.osim', 'l_knee.trc', ...
    markerNames, 'finish.sto')

% Create the plot. A value of false means each pair is plotted separately,
% a value of true means all are plotted together.
plotMarkerDistanceErrors(["start.sto", "finish.sto"], false)