% This function is part of the NMSM Pipeline, see file for full license.
%
% 
%
% (struct, string, string) -> (None)
% Write replaced experimental ground reactions to an OpenSim Storage file.

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

function writeReplacedExperimentalGroundReactionsToSto(inputs, ...
    resultsDirectory, modelName)
columnLabels = ["Fx" "Fy" "Fz" "Mx" "My" "Mz" "ECx" "ECy" "ECz"];
for foot = 1:length(inputs.surfaces)
    data = inputs.surfaces{foot}.experimentalGroundReactionForces';

    for i = 1 : size( ...
            inputs.surfaces{foot}.experimentalGroundReactionMoments, 2)
        inputs.surfaces{foot} ...
            .experimentalGroundReactionMoments(:, i) = ...
            inputs.surfaces{foot} ...
            .experimentalGroundReactionMoments(:, i) + ...
            cross([inputs.surfaces{foot}.electricalCenterShift(1); 0; ...
            inputs.surfaces{foot}.electricalCenterShift(2)], ...
            inputs.surfaces{foot}.experimentalGroundReactionForces(:, i));
    end

    data = [data inputs.surfaces{foot}.experimentalGroundReactionMoments'];
%     [~, markerPositions] = ...
%         makeFootKinematics(inputs.bodyModel, ...
%         inputs.motionFileName, ...
%         inputs.surfaces{foot}.coordinatesOfInterest, ...
%         inputs.surfaces{foot}.hindfootBodyName, ...
%         inputs.surfaces{foot}.toesCoordinateName, ...
%         inputs.surfaces{foot}.markerNames, ...
%         inputs.surfaces{foot}.time(1), inputs.surfaces{foot}.time(end), ...
%         inputs.surfaces{foot}.isLeftFoot);
%     markerPositions.midfootSuperior(2, :) = inputs.restingSpringLength;
    data = [data inputs.surfaces{foot}.experimentalMomentCenter'];
    writeToSto(columnLabels, inputs.surfaces{foot}.time, data, ...
        fullfile(resultsDirectory, strcat(modelName, "_Foot_", ...
            num2str(foot), "_replacedExperimentalGroundReactions.sto")));
end
end

