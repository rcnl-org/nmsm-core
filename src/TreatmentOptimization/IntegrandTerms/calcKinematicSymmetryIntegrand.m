% This function is part of the NMSM Pipeline, see file for full license.
%
% This function calculates kinematic symmetry, or the difference between 
% two joint angles. Kinematic symmetry is calculated as the difference 
% between one joint angle and the second joint angle with a 50% phase
% shift. To use this term, an even number is encouraged for the
% <setup_mesh_phase_intervals> tag in the optimal control settings.
% Additionally, two coordinate names are required to calculate the
% difference. 
%
% (2D matrix, struct, struct) -> (Array of number)
%

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Marleny Vega                                                 %
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

function cost = calcKinematicSymmetryIntegrand(statePositions, auxdata, ...
    costTerm)

halfWayFrame = size(statePositions, 1)/2;

indx1 = find(strcmp(convertCharsToStrings(auxdata.coordinateNames), ...
    costTerm.coordinate1));
indx2 = find(strcmp(convertCharsToStrings(auxdata.coordinateNames), ...
    costTerm.coordinate2));

cost = calcTrackingCostArrayTerm(statePositions(:,indx1), ...
    [statePositions(1 + round(halfWayFrame):end, indx2); ...
    statePositions(1:round(halfWayFrame), indx2)], 1);
end