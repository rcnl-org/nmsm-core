% This function is part of the NMSM Pipeline, see file for full license.
%
% This function returns an isolated foot model with spring markers and its 
% associated kinematics expressed in its seven coordinates (toe angle, 
% three hindfoot rotations, three hindfoot translations).
%
% (string, string, string, string, string, string, struct, double, double, 
% logical) -> (Model, Array of double, Array of double)
% Create foot model and kinematics in seven coordinates.

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

function [footModel, footPosition, footVelocity] = prepareModel( ...
    modelName, motionFileName, hindfootBodyName, toesBodyName, ...
    toesJointName, toesCoordinateName, markerNames, gridWidth, ...
    gridHeight, isLeftFoot)

import org.opensim.modeling.Storage

model = Model(modelName);
time = findTimeColumn(Storage(motionFileName));
coordinatesOfInterest = findGCPFreeCoordinates(model, toesBodyName);

footPosition = makeFootKinematics(model, motionFileName, ...
    coordinatesOfInterest, hindfootBodyName, toesCoordinateName);
footVelocity = calcDerivative(time, footPosition);

footModel = makeFootModel(model, toesJointName);
footModel = addSpringsToModel(footModel, markerNames, gridWidth, ...
    gridHeight, hindfootBodyName, toesBodyName, isLeftFoot);
end

