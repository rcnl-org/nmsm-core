% This function is part of the NMSM Pipeline, see file for full license.
%
% This function calculates the error in braking impulse for the side
% defined in the cost term. Only the braking impulse (negative) is
% included in the output.
%
% (struct, Array of double, struct, struct) -> (Array of double)

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

function cost = calcBrakingImpulseGoalIntegrand(modeledValues, ...
    time, inputs, costTerm)
if isfield(costTerm, 'internalSurfaceIndex')
    surfaceIndex = costTerm.internalSurfaceIndex;
else
    hindfootBodyName = getTermFieldOrError(costTerm, 'hindfoot_body');
    surfaceIndex = 0;
    for j = 1 : length(inputs.contactSurfaces)
        if strcmp(inputs.contactSurfaces{j}.hindfootBodyName, ...
                hindfootBodyName)
            surfaceIndex = j;
        end
    end
    assert(surfaceIndex ~= 0, hindfootBodyName + ...
        " is not a contact surface hindfoot body.");
    
    costTerm.internalSurfaceIndex = surfaceIndex;
end

assert(isfield(costTerm, 'errorCenter'), "Impulse goal terms " + ...
    "require an <error_center>.");
cost = ((modeledValues.brakingImpulse(surfaceIndex) - costTerm.errorCenter) ...
    ./ costTerm.maxAllowableError) .^ 2;
end
