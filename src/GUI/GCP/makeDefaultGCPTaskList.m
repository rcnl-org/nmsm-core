% This function is part of the NMSM Pipeline, see file for full license.
%
% Builds the three round Ground Contact Personalization task sequence
% that a GCP run normally starts from, matching the task list in the
% advanced tutorial's GCP_Settings_Coulomb.xml.
%
% Each round calibrates one part of the ground reaction in turn and is
% told to by its allowable errors: the quantity a round is responsible
% for gets a tight error and the rest stay loose, so the optimizer spends
% that round on it.
%
%   1  Vertical Force    springs, damping, dynamic friction, and resting
%                        length, with the vertical force held to 5 N
%                        while the horizontal force and moment sit at 20.
%   2  Horizontal Force  drops damping and resting length, keeps the
%                        dynamic friction coefficient, and tightens the
%                        horizontal force to 5 N.
%   3  Moments           frees the fore-aft and medial-lateral electrical
%                        center shifts and tightens the moment to 0.5 Nm.
%
% Spring constants and the kinematics B-spline coefficients are optimized
% in every round, and marker position, rotation, and the neighbor spring
% constant are tracked throughout to keep the foot on its measured path
% and the stiffness field smooth.
%
% (None) -> (Cell array of GCPTaskClass)
% Returns the default GCP task sequence.

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2026 Rice University and the Authors                      %
% Author(s): Robert Salati                                                %
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

function tasks = makeDefaultGCPTaskList()

taskNames = ["Vertical Force", "Horizontal Force", "Moments"];

% One row per task, columns in GCPTaskClass.parameterNames order:
% springConstants, dampingFactor, dynamicFrictionCoefficient,
% viscousFrictionCoefficient, restingSpringLength,
% kinematicsBSplineCoefficients, electricalCenterX, electricalCenterY,
% electricalCenterZ, forcePlateRotation.
designVariables = [ ...
    true  true  true false true  true  false false false false
    true  false true  false false true  false false false false
    true  false true  false false true  true  false true  false];

% Allowable error per task for each cost term the sequence enables. The
% column that drops is the round's focus.
costTermErrors = struct( ...
    'marker_position',          [0.002 0.002 0.002], ...
    'rotation',                 [0.01  0.01  0.01], ...
    'vertical_grf',             [5     5     5], ...
    'horizontal_grf',           [20    5     5], ...
    'ground_reaction_moment',   [20    20    0.5], ...
    'neighbor_spring_constant', [1000  1000  1000]);

neighborStandardDeviation = 0.3;

costTermTypes = fieldnames(costTermErrors);
tasks = cell(1, length(taskNames));
for i = 1 : length(taskNames)
    task = GCPTaskClass();
    task.name = taskNames(i);
    % The backend runs the tasks in index order, so it has to match the
    % position in the list.
    task.index = i;
    task.is_enabled = 'true';
    for j = 1 : length(task.parameterNames)
        task.setParameterValueByIndex(j, ...
            boolToString(designVariables(i, j)));
    end
    task.neighborStandardDeviation = neighborStandardDeviation;
    for j = 1 : length(costTermTypes)
        costTerm = findCostTermByType(task, costTermTypes{j});
        costTerm.is_enabled = 'true';
        costTerm.max_allowable_error = costTermErrors.(costTermTypes{j})(i);
    end
    tasks{i} = task;
end
end

% (GCPTaskClass, char) -> (RCNLCostTermClass)
function costTerm = findCostTermByType(task, type)
for i = 1 : length(task.RCNLCostTerm)
    if strcmp(string(task.RCNLCostTerm{i}.type), type)
        costTerm = task.RCNLCostTerm{i};
        return
    end
end
% Only reachable if GCPTaskClass.costTermStruct loses a type this
% sequence relies on, which is a mistake worth naming rather than
% silently building a task without the term.
throw(MException('', ['GCPTaskClass has no cost term of type ' type]))
end
