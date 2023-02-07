% This function is part of the NMSM Pipeline, see file for full license.
%
% 
%
% (struct, struct) -> (struct)
% Optimize ground contact parameters according to Jackson et al. (2016)

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Claire V. Hammond, Spencer Williams                          %
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

function inputs = initializeRestingSpringLength(inputs, params)
[modeledJointPositions, modeledJointVelocities] = calcGCPJointKinematics( ...
    inputs.experimentalJointPositions, inputs.jointKinematicsBSplines, ...
    ones(25, 7));
springHeights = zeros(size(modeledJointPositions, 2), ...
    length(inputs.springConstants));
springVelocities = springHeights;

% xVel = springHeights;
% zVel = springHeights;

[model, state] = Model(inputs.model);
for i=1:size(modeledJointPositions, 2)
    [model, state] = updateModelPositionAndVelocity(model, state, ...
        modeledJointPositions(:, i), ...
        modeledJointVelocities(:, i));
    for j = 1:length(inputs.springConstants)
        springHeights(i, j) = model.getMarkerSet().get("spring_marker_" + ...
            num2str(j)).getLocationInGround(state).get(1);
        springVelocities(i, j) = model.getMarkerSet().get("spring_marker_" + ...
            num2str(j)).getVelocityInGround(state).get(1);
        
%         xVel(i, j) = model.getMarkerSet().get("spring_marker_" + ...
%             num2str(j)).getVelocityInGround(state).get(0) + inputs.beltSpeed;
%         zVel(i, j) = model.getMarkerSet().get("spring_marker_" + ...
%             num2str(j)).getVelocityInGround(state).get(2);
    end
end

% Plot spring marker heights
% hold on
% for i = 1:length(inputs.springConstants)
%     style = '-';
%     plot(inputs.time, springHeights(:, i), style)
% end
% plot(inputs.time, ones(1, 101) * 0.0309)
% plot(inputs.time, ones(1, 101) * 0.0363)
% plot(inputs.time, ones(1, 101) * 0.0509)
% verticalForce = inputs.experimentalGroundReactionForces(2, :);
% plot(inputs.time, verticalForce/5000)
% hold off
% xForce = inputs.experimentalGroundReactionForces(1, :);
% figure(1);
% hold on
% for i = 1:length(inputs.springConstants)
%     style = '-';
%     plot(inputs.time, xVel(:, i), style)
% end
% hold off
% figure(2);
% hold on
% for i = 1:length(inputs.springConstants)
%     style = '-';
%     plot(inputs.time, zVel(:, i), style)
% end
% hold off
% figure(1);
% hold on;
% slipVel = zeros(size(xVel));
% for i = 1:length(inputs.springConstants)
%     slipVel(:, i) = sqrt(xVel(:, i).^2 + zVel(:, i).^2);
%     style = '-';
%     plot(inputs.time(4:71), slipVel(4:71, i), style)
% end
% plot(inputs.time(4:71), ones(1, 71 - 3) * 0.05);
% verticalForce = inputs.experimentalGroundReactionForces(2, :);
% plot(inputs.time(4:71), verticalForce(4:71)/500)
% hold off;



inputs.restingSpringLength = lsqnonlin( ...
    @(restingSpringLength) calcRestingSpringLengthCost( ...
    restingSpringLength, inputs, params, springHeights, springVelocities), ...
    inputs.initialRestingSpringLength, [], []);

inputs.experimentalGroundReactionMoments = ...
    replaceMomentsAboutMidfootSuperior(inputs);
inputs.experimentalGroundReactionMomentsSlope = calcBSplineDerivative( ...
    inputs.time, inputs.experimentalGroundReactionMoments, 2, ...
    params.splineNodes);
end

function cost = calcRestingSpringLengthCost(restingSpringLength, ...
    inputs, params, springHeights, springVelocities)
verticalForce = inputs.experimentalGroundReactionForces(2, :);
modeledVerticalGrf = zeros(size(verticalForce));
for i = 1:length(modeledVerticalGrf)
    for j = 1:length(inputs.springConstants)
        height = springHeights(i, j);
        velocity = springVelocities(i, j);
        klow = 1e-1;
        h = 1e-3;
        c = 5e-4;
        ymax = 1e-2;
        Kval = inputs.springConstants(j);
        height = height - restingSpringLength;
        numFrames = length(height);
        v = ones(numFrames, 1)' .* ((Kval + klow) ./ (Kval - klow));
        s = ones(numFrames, 1)' .* ((Kval - klow) ./ 2);
        constant = -s .* (v .* ymax - c .* log(cosh((ymax + h) ./ c)));
        freglyVerticalGrf = -s .* (v .* height - c .* log(cosh((height + h) ./ c))) - constant;
        freglyVerticalGrf(isnan(freglyVerticalGrf)) = min(min(freglyVerticalGrf));
        freglyVerticalGrf(isinf(freglyVerticalGrf)) = min(min(freglyVerticalGrf));
        modeledVerticalGrf(i) = modeledVerticalGrf(i) + freglyVerticalGrf * (1 + inputs.dampingFactors(j) * ...
            velocity);
    end
end
cost = sqrt(1 / 101) * (verticalForce - modeledVerticalGrf);
end

function [model, state] = updateModelPositionAndVelocity(model, state, ...
    jointPositions, jointVelocities)
for j=1:size(jointPositions, 1)
    model.getCoordinateSet().get(j-1).setValue(state, ...
        jointPositions(j));
    model.getCoordinateSet().get(j-1).setSpeedValue(state, ...
        jointVelocities(j));
end
model.assemble(state)
model.realizeVelocity(state)
end

% (struct) -> (2D Array of double)
% Replace parsed experimental ground reaction moments about midfoot
% superior marker projected onto floor
function replacedMoments = replaceMomentsAboutMidfootSuperior(inputs)
    replacedMoments = ...
        zeros(size(inputs.experimentalGroundReactionMoments));
    for i = 1:size(replacedMoments, 2)
        newCenter = inputs.midfootSuperiorPosition(:, i);
        newCenter(2) = inputs.restingSpringLength;
        replacedMoments(:, i) = ...
            inputs.experimentalGroundReactionMoments(:, i) + ...
            cross((inputs.electricalCenter(:, i) - newCenter), ...
            inputs.experimentalGroundReactionForces(:, i));
    end
end
