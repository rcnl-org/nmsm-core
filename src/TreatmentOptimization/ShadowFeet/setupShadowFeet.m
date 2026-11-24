% This function is part of the NMSM Pipeline, see file for full license.
%
% This function prepares Treatment Optimization to use shadow feet when
% <use_shadow_feet> is true. It:
%   1) adds a shadow foot for each contact surface to the model,
%   2) calculates shadow foot coordinates from the experimental and
%      initial guess kinematics and appends them as new coordinates,
%   3) adds the shadow foot coordinates to the states coordinates,
%   4) splits the shadow foot constraint terms (shadow_foot_position,
%      shadow_foot_orientation, shadow_foot_velocity, and
%      shadow_foot_angular_velocity) into one term per shadow foot
%      coordinate.
% Nothing is written except the model file with the shadow feet.
%
% (struct) -> (struct)
% Sets up shadow feet for Treatment Optimization

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

function inputs = setupShadowFeet(inputs)
if ~valueOrAlternate(inputs, 'useShadowFeet', false)
    return
end
originalModelFileName = inputs.modelFileName;
[inputs.modelFileName, inputs.contactSurfaces] = ...
    addShadowFeetToModel(originalModelFileName, inputs.contactSurfaces);
inputs.model = Model(inputs.modelFileName);

for i = 1 : length(inputs.contactSurfaces)
    assert(any(strcmp(inputs.coordinateNames, ...
        inputs.contactSurfaces{i}.toesCoordinateName)), "Shadow feet " + ...
        "require the toe coordinate " + ...
        inputs.contactSurfaces{i}.toesCoordinateName + ...
        " to be in the IK data")
end

[shadowAngles, shadowNames] = calcShadowFootCoordinates( ...
    originalModelFileName, inputs.experimentalJointAngles, ...
    inputs.coordinateNames, inputs.contactSurfaces);
inputs.experimentalJointAngles = [inputs.experimentalJointAngles, ...
    shadowAngles];
inputs.coordinateNamesStrings = [ ...
    reshape(string(inputs.coordinateNamesStrings), 1, []), shadowNames];
inputs.coordinateNames = cellstr(inputs.coordinateNamesStrings);

initialShadowAngles = calcShadowFootCoordinates(originalModelFileName, ...
    inputs.initialJointAngles, inputs.initialCoordinateNames, ...
    inputs.contactSurfaces);
inputs.initialJointAngles = [inputs.initialJointAngles, ...
    initialShadowAngles];
inputs.initialCoordinateNames = [ ...
    reshape(string(inputs.initialCoordinateNames), 1, []), shadowNames];

inputs.statesCoordinateNames = [ ...
    reshape(string(inputs.statesCoordinateNames), 1, []), ...
    shadowNames(~ismember(shadowNames, ...
    string(inputs.statesCoordinateNames)))];
inputs.statesCoordinateIndices = zeros(size(inputs.statesCoordinateNames));
for i = 1 : length(inputs.statesCoordinateNames)
    inputs.statesCoordinateIndices(i) = find(strcmp( ...
        inputs.coordinateNames, inputs.statesCoordinateNames(i)));
end

for i = 1 : length(inputs.contactSurfaces)
    inputs.contactSurfaces{i}.toesCoordinateIndex = find(strcmp( ...
        inputs.coordinateNames, ...
        inputs.contactSurfaces{i}.toesCoordinateName));
    inputs.contactSurfaces{i}.shadowCoordinateIndices = zeros(1, 7);
    for j = 1 : 7
        inputs.contactSurfaces{i}.shadowCoordinateIndices(j) = ...
            find(strcmp(inputs.coordinateNames, ...
            inputs.contactSurfaces{i}.shadowCoordinateNames(j)));
    end
end

% The shadow feet are independent of the rest of the model and have no
% applied loads, so their coordinates do not change the inverse dynamics
% of the model's coordinates. They are left out of the inverse dynamics
% calls. This keeps their values out of the acceleration matching by
% value (a shadow toe angle equal to the model's toe angle could take its
% acceleration), and avoids a crash seen with the Windows inverse dynamics
% MEX functions (OpenSim 4.5), which throw when more than six threads set
% the shadow foot ground coordinates.
inputs.inverseDynamicsCoordinateIndices = find(~ismember( ...
    inputs.coordinateNames, cellstr(shadowNames)));
% Inverse dynamics returns loads in the model's generalized coordinate (Q)
% order, which the shadow feet change (their joints attach to ground, so
% their coordinates are not all last). Keep only the model's own
% coordinates, which are left in their original order.
inputs.inverseDynamicsOutputColumns = findNonShadowQColumns( ...
    inputs.model, shadowNames);

inputs = removeInitialStateValues(inputs);
inputs.path = splitShadowFootTerms(inputs.path, ...
    inputs.contactSurfaces);
end

% Simbody orders the generalized coordinates by mobilized body, then by
% coordinate within the mobilizer.
function columns = findNonShadowQColumns(model, shadowNames)
coordinateSet = model.getCoordinateSet();
numCoordinates = coordinateSet.getSize();
qOrderKeys = zeros(numCoordinates, 2);
isShadow = false(1, numCoordinates);
for i = 1 : numCoordinates
    coordinate = coordinateSet.get(i - 1);
    qOrderKeys(i, :) = [double(coordinate.getBodyIndex()), ...
        double(coordinate.getMobilizerQIndex())];
    isShadow(i) = ismember(string(coordinate.getName()), shadowNames);
end
[~, qOrder] = sortrows(qOrderKeys);
columns = find(~isShadow(qOrder));
end

% An initial guess states file was parsed before the shadow foot
% coordinates existed, so it cannot include them. The initial guess falls
% back to the initial guess IK data, which now includes the shadow feet.
function inputs = removeInitialStateValues(inputs)
fields = ["initialStates", "initialStatesLabels", ...
    "initialAccelerations", "initialAccelerationsLabels", ...
    "initialJerks", "initialJerkLabels"];
fields = fields(isfield(inputs, fields));
if any(fields == "initialStates")
    warning("Shadow feet: the initial guess states, accelerations, " + ...
        "and jerks files are ignored. The initial guess is made " + ...
        "from the initial guess IK data instead.")
end
for i = 1 : length(fields)
    inputs = rmfield(inputs, fields(i));
end
end

% Each shadow foot term becomes one term per shadow foot coordinate it
% covers, so that every constraint term has a single column, as the
% solvers expect. Components index contactSurfaces{i}.shadowCoordinateNames
% (toe angle, three rotations, three translations): position covers the
% translations, orientation the rotations and the toe angle, and the
% velocity terms the speeds of the same coordinates.
function newTerms = splitShadowFootTerms(terms, contactSurfaces)
types = ["shadow_foot_position", "shadow_foot_orientation", ...
    "shadow_foot_velocity", "shadow_foot_angular_velocity"];
components = {5 : 7, 1 : 4, 5 : 7, 1 : 4};
isVelocity = [false, false, true, true];
newTerms = {};
for i = 1 : length(terms)
    typeIndex = find(strcmp(types, terms{i}.type), 1);
    if isempty(typeIndex)
        newTerms{end + 1} = terms{i};
        continue
    end
    for surface = 1 : length(contactSurfaces)
        for component = components{typeIndex}
            newTerm = terms{i};
            newTerm.shadowSurfaceIndex = surface;
            newTerm.shadowComponentIndex = component;
            newTerm.shadowIsVelocity = isVelocity(typeIndex);
            newTerm.coordinate = convertStringsToChars( ...
                contactSurfaces{surface}.shadowCoordinateNames(component));
            newTerms{end + 1} = newTerm;
        end
    end
end
end
