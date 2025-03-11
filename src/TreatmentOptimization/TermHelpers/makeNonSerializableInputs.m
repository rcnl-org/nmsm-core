% This function is part of the NMSM Pipeline, see file for full license.
%
% (struct, string, struct, struct, struct) -> (2D matrix)
% 
% Remakes non-serializable items for Treatment Optimization inputs struct.

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

function nonSerialInputs = makeNonSerializableInputs(inputs, removedTerms)
nonSerialInputs = cell(1, length(removedTerms));
% Model
if removedTerms(1)
    nonSerialInputs{1} = Model(inputs.modelFileName);
end
% splineJointAngles
if removedTerms(2)
    nonSerialInputs{2} = makeGcvSplineSet(inputs.experimentalTime, ...
        inputs.experimentalJointAngles', inputs.coordinateNames);
end
% splineJointMoments
if removedTerms(3)
    nonSerialInputs{3} = makeGcvSplineSet(inputs.experimentalTime, ...
        inputs.experimentalJointMoments, ...
        inputs.inverseDynamicsMomentLabels);
end
% splineSynergyActivations
if removedTerms(4)
    nonSerialInputs{4} = makeGcvSplineSet( ...
        inputs.initialTime, inputs.initialSynergyControls', ...
        inputs.initialSynergyControlsLabels);
end
% splineMuscleActivations
if removedTerms(5)
    nonSerialInputs{5} = makeGcvSplineSet( ...
        inputs.experimentalTime, inputs.experimentalMuscleActivations, ...
        inputs.muscleLabels);
end
% splineTorqueControls
if removedTerms(6)
    nonSerialInputs{6} = makeGcvSplineSet(inputs.initialTime, ...
        inputs.initialTorqueControls', inputs.initialTorqueControlsLabels);
end
% splineMarkerPositions
if removedTerms(7)
    % nonSerialInputs{7} = 
end
% splineMarkerVelocities
if removedTerms(8)
    % nonSerialInputs{8} = 
end
% splineExperimentalGroundReactionForces
if removedTerms(9)
    splineSets = cell(1, length(inputs.contactSurfaces));
    for i = 1:length(inputs.contactSurfaces)
        splineSets{i} = ...
            makeGcvSplineSet(inputs.experimentalTime, ...
            inputs.contactSurfaces{i}.experimentalGroundReactionForces, ...
            string(0:2));
    end
    nonSerialInputs{9} = splineSets;
end
% splineExperimentalGroundReactionMoments
if removedTerms(10)
    splineSets = cell(1, length(inputs.contactSurfaces));
    for i = 1:length(inputs.contactSurfaces)
        splineSets{i} = ...
            makeGcvSplineSet(inputs.experimentalTime, ...
            inputs.contactSurfaces{i}.experimentalGroundReactionMoments, ...
            string(0:2));
    end
    nonSerialInputs{10} = splineSets;
end
end
