% This function is part of the NMSM Pipeline, see file for full license.
%
% This function first calculates the midfoot superior location and then 
% transfers the ground reaction moments from the electrical center to the 
% midfoot superior location.
%
% (struct) -> (struct)
% Transfers the ground reaction moments to the midfoot superior location

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

function inputs = setupGroundContact(inputs)
for i = 1:length(inputs.contactSurfaces)
    midfootSuperiorLocation = pointKinematics(inputs.experimentalTime, ...
        inputs.experimentalJointAngles, inputs.experimentalJointVelocities, ...
        inputs.contactSurfaces{i}.midfootSuperiorPointOnBody, ...
        inputs.contactSurfaces{i}.midfootSuperiorBody, ...
        inputs.modelFileName, inputs.coordinateNames, inputs.osimVersion);
    midfootSuperiorLocation(:, 2) = inputs.contactSurfaces{i}.restingSpringLength;
    inputs.contactSurfaces{i}.experimentalGroundReactionMoments = ...
        transferMoments(inputs.contactSurfaces{i}.electricalCenter, ...
        midfootSuperiorLocation, ...
        inputs.contactSurfaces{i}.experimentalGroundReactionMoments, ...
        inputs.contactSurfaces{i}.experimentalGroundReactionForces);
end
end
