% This function is part of the NMSM Pipeline, see file for full license.
%
% () -> ()
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

function trailingLimbAngle = calcTrailingLimb(costTerm, values, ...
    normalForce, params)

fifthMetarsalLocation = calcBodyLocation(values, str2num( ...
    costTerm.toe_point), costTerm.toe_body, params);
greaterTrochanterLocation = calcBodyLocation(values, str2num( ...
    costTerm.femur_point), costTerm.femur_body, params);

normalForce(normalForce<0) = 0;
slope = diff(normalForce);
toeOffEvent = getToeOffEvent(slope);

if ~isempty(toeOffEvent)
    trailingLimbVector = fifthMetarsalLocation(toeOffEvent, :) - ...
        greaterTrochanterLocation(toeOffEvent, :);
    trailingLimbUnitVector = trailingLimbVector/norm(trailingLimbVector);
    dotProduct = dot(trailingLimbUnitVector, [0 -1 0]);
    trailingLimbAngle = acosd(dotProduct);
else 
    trailingLimbAngle = 0;
end
end