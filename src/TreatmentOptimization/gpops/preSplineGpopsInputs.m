% This function is part of the NMSM Pipeline, see file for full license.
%
%

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

function splinedSetup = preSplineGpopsInputs(setup)
tempSetup = makeMinimalSetup(setup);
collocationPointTimes = findCollocationPointsForSetup(tempSetup);
splinedSetup = applyPreSpline(setup, collocationPointTimes);
end

function collocationPointTimes = findCollocationPointsForSetup(tempSetup)
output = gpops2(tempSetup);
collocationPointTimes = output.result.solution.phase.timeRadau;
end

function setup = applyPreSpline(setup, collocationPointTimes)
setup.auxdata.collocationTimeBound = collocationPointTimes;
time = scaleToOriginal(collocationPointTimes, setup.auxdata.maxTime, ...
    setup.auxdata.minTime);
setup.auxdata.collocationTimeOriginal = time;

setup.auxdata.splinedJointAngles = evaluateGcvSplines(setup.auxdata.splineJointAngles, ...
    setup.auxdata.coordinateNames, time, 0);
setup.auxdata.splinedJointSpeeds = evaluateGcvSplines(setup.auxdata.splineJointAngles, ...
    setup.auxdata.coordinateNames, time, 1);
setup.auxdata.splinedJointAccelerations = evaluateGcvSplines(setup.auxdata.splineJointAngles, ...
    setup.auxdata.coordinateNames, time, 2);
setup.auxdata.splinedJointMoments = evaluateGcvSplines(setup.auxdata.splineJointMoments, ...
    setup.auxdata.inverseDynamicsMomentLabels, time, 0);
if strcmp(setup.auxdata.controllerType, 'synergy') && ...
        isfield(setup.auxdata, 'splineSynergyActivations')
    setup.auxdata.splinedSynergyActivations = evaluateGcvSplines( ...
        setup.auxdata.splineSynergyActivations, ...
        setup.auxdata.synergyLabels, time, 0);
end
if strcmp(setup.auxdata.controllerType, 'synergy') && ...
        isfield(setup.auxdata, 'splineMuscleActivations')
    setup.auxdata.splinedMuscleActivations = evaluateGcvSplines( ...
        setup.auxdata.splineMuscleActivations, setup.auxdata.muscleLabels, time, 0);
end
if isfield(setup.auxdata, 'torqueControllerCoordinateNames') && ...
        ~isempty(setup.auxdata.torqueControllerCoordinateNames)
    setup.auxdata.splinedTorqueControls = evaluateGcvSplines( ...
        setup.auxdata.splineTorqueControls, setup.auxdata.torqueLabels, time, 0);
end
if isfield(setup.auxdata, "splineMarkerPositions")
    for i = 1:length(setup.auxdata.splineMarkerPositions)
        setup.auxdata.splinedMarkerPositions{i} = evaluateGcvSplines( ...
            setup.auxdata.splineMarkerPositions{i}, 0:2, time, 0);
    end
end
for i = 1:length(setup.auxdata.contactSurfaces)
    setup.auxdata.splinedGroundReactionForces{i} = evaluateGcvSplines( ...
        setup.auxdata.splineExperimentalGroundReactionForces{i}, 0:2, time, 0);
    setup.auxdata.splinedGroundReactionMoments{i} = evaluateGcvSplines( ...
        setup.auxdata.splineExperimentalGroundReactionMoments{i}, 0:2, time, 0);
end
end

function tempSetup = makeMinimalSetup(setup)
tempSetup.name = 'Test';
tempSetup.functions.continuous = @continuous;
tempSetup.functions.endpoint = @endpoint;

tempSetup.guess.phase.time = setup.guess.phase.time;

tempSetup.guess.phase.state = zeros(size(tempSetup.guess.phase.time));
tempSetup.guess.phase.control = zeros(size(tempSetup.guess.phase.time));
tempSetup.guess.phase.integral = 0;

tempSetup.bounds.phase.initialtime.lower = tempSetup.guess.phase.time(1);
tempSetup.bounds.phase.initialtime.upper = tempSetup.guess.phase.time(1);
tempSetup.bounds.phase.finaltime.lower = tempSetup.guess.phase.time(end);
tempSetup.bounds.phase.finaltime.upper = tempSetup.guess.phase.time(end);
tempSetup.bounds.phase.initialstate.lower = -1;
tempSetup.bounds.phase.initialstate.upper = 1;
tempSetup.bounds.phase.state.lower = -1;
tempSetup.bounds.phase.state.upper = 1;
tempSetup.bounds.phase.finalstate.lower = -1;
tempSetup.bounds.phase.finalstate.upper = 1;
tempSetup.bounds.phase.control.lower = -1;
tempSetup.bounds.phase.control.upper = 1;
tempSetup.bounds.phase.integral.lower = -1;
tempSetup.bounds.phase.integral.upper = 1;
tempSetup.derivatives.derivativelevel= 'first';
tempSetup.nlp.ipoptoptions.maxiterations = 1;
tempSetup.scales.method = 'none';

tempSetup.mesh.phase.colpoints = setup.mesh.phase.colpoints;
tempSetup.mesh.phase.fraction = setup.mesh.phase.fraction;
tempSetup.mesh.maxiterations = 0;
tempSetup.displaylevel = 0;
end

function output = continuous(input)
output.dynamics = zeros(size(input.phase.time));
output.integrand = zeros(size(input.phase.time));
end

function output = endpoint(input)
output.objective = input.phase.integral;
end