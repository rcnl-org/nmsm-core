% This function is part of the NMSM Pipeline, see file for full license.
%
% (struct, struct) -> (None)
% Plot GCP stiffness values from model and osimx files. 

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

function plotGcpStiffnessCoefficients(modelFileName, osimxFileName, ...
    surfaceNumber)
% Parse inputs
params = getPlottingParams();
[model, state] = Model(modelFileName);
osimx = parseOsimxFile(osimxFileName, model);
if nargin < 3
    surfaceNumber = 1;
end
contactSurface = getFieldByNameOrError(osimx, 'contactSurface');
assert(iscell(contactSurface), "The given .osimx file does not " + ...
    "contain contact surfaces.")
assert(surfaceNumber <= length(contactSurface), "Contact surface " + ...
    "number is out of range.")
contactSurface = contactSurface{1};

% Get toes body name
joints = getBodyJointNames(model, contactSurface.hindfootBodyName);
assert(length(joints) == 2, "GCP supports two segment foot models only");
for i = 1 : length(joints)
    [parent, ~] = getJointBodyNames(model, joints(i));
    if strcmp(parent, contactSurface.hindfootBodyName)
        toesJointName = joints(i);
        break
    end
end
assert(model.getJointSet().get(toesJointName) ...
    .numCoordinates() == 1, "GCP toes joint must be a pin joint");
[~, toesBodyName] = getJointBodyNames(model, toesJointName);

% Get spring locations in common reference frame
calcnToToes = model.getBodySet().get(toesBodyName) ...
    .findTransformBetween(state, model.getBodySet() ...
    .get(contactSurface.hindfootBodyName));
xOffset = calcnToToes.T.get(0);
zOffset = calcnToToes.T.get(2);
springX = zeros(1, length(contactSurface.springs));
springZ = zeros(1, length(contactSurface.springs));
stiffness = zeros(1, length(contactSurface.springs));
for i = 1 : length(contactSurface.springs)
    position = contactSurface.springs{i}.location;
    offset = strcmp(contactSurface.springs{i}.parentBody, toesBodyName);
    springX(i) = position(1) + xOffset * offset;
    springZ(i) = position(3) + zOffset * offset;
    stiffness(i) = contactSurface.springs{i}.springConstant;
end

% Plot values
figure(name = osimxFileName)
set(gcf, color=params.plotBackgroundColor)
scatter(springZ, springX, 200, stiffness, "filled")
set(gca, ...
        fontsize = params.tickLabelFontSize, ...
        color=params.subplotBackgroundColor)
set(gca, 'DataAspectRatio', [1, 1, 1])
title("Stiffness coefficients", ...
        fontsize = params.subplotTitleFontSize)
xlabel("Z location on foot (m)", ...
    fontsize=params.axisLabelFontSize)
ylabel("X location on foot (m)", ...
    fontsize=params.axisLabelFontSize)

R = [254 254 236 204 153];
G = [196 153 112 76 52];
B = [79 41 20 2 4];
R = interp1(linspace(R(1), R(end), numel(R)), R, linspace(R(1), R(end), 50));
B = interp1(linspace(B(1), B(end), numel(B)), B, linspace(B(1), B(end), 50));
G = interp1(linspace(G(1), G(end), numel(G)), G, linspace(G(1), G(end), 50));
colors = [R', G', B']/255;
colormap(colors)
colorbar
end