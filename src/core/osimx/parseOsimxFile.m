% This function is part of the NMSM Pipeline, see file for full license.
%
% This function parses the osimx file
%
% (str) -> (struct)
% Creates .osimxStruct

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Claire V. Hammond, Marleny Vega, Spencer Williams            %
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

function osimx = parseOsimxFile(osimxFileName)

if strcmp(osimxFileName, "")
    osimx = struct();
    return
else
    tree = xml2struct(osimxFileName);
end

osimx.model = getFieldByNameOrError(tree, "associated_osim_model").Text;
osimx.modelName = getFieldByNameOrError(tree, "OsimxModel").Attributes.name;

rcnlGroundContactTree = getFieldByName(tree, "RCNLContactSurfaceSet");
if(isstruct(rcnlGroundContactTree))

    contactSurfaceTree = getFieldByNameOrError(rcnlGroundContactTree, "objects").RCNLContactSurface;

    for i = 1:length(contactSurfaceTree)
        if length(contactSurfaceTree) == 1
            contactSurface = contactSurfaceTree;
        else
            contactSurface = contactSurfaceTree{i};
        end
        osimx.groundContact.contactSurface{i} = parseContactSurface(contactSurface);
    end
end

rcnlMuscleSetTree = getFieldByName(tree, "RCNLMuscleSet");
if(isstruct(rcnlMuscleSetTree))
    musclesTree = getFieldByNameOrError(rcnlMuscleSetTree, "objects").RCNLMuscle;

    for i = 1:length(musclesTree)
        if length(musclesTree) == 1
            muscle = musclesTree;
        else
            muscle = musclesTree{i};
        end
        if isstruct(getFieldByName(muscle, 'electromechanical_delay'))
            osimx.muscles.(muscle.Attributes.name).electromechanicalDelay = str2double(muscle.electromechanical_delay.Text);
        end
        if isstruct(getFieldByName(muscle, 'activation_time_constant'))
            osimx.muscles.(muscle.Attributes.name).activationTimeConstant = str2double(muscle.activation_time_constant.Text);
        end
        if isstruct(getFieldByName(muscle, 'activation_nonlinearity_constant'))
            osimx.muscles.(muscle.Attributes.name).activationNonlinearityConstant = str2double(muscle.activation_nonlinearity_constant.Text);
        end
        if isstruct(getFieldByName(muscle, 'emg_scale_factor'))
            osimx.muscles.(muscle.Attributes.name).emgScaleFactor = str2double(muscle.emg_scale_factor.Text);
        end
        if isstruct(getFieldByName(muscle, 'optimal_fiber_length'))
            osimx.muscles.(muscle.Attributes.name).optimalFiberLength = str2double(muscle.optimal_fiber_length.Text);
        end
        if isstruct(getFieldByName(muscle, 'tendon_slack_length'))
            osimx.muscles.(muscle.Attributes.name).tendonSlackLength = str2double(muscle.tendon_slack_length.Text);
        end
        if isstruct(getFieldByName(muscle, 'max_isometric_force'))
            osimx.muscles.(muscle.Attributes.name).maxIsometricForce = str2double(muscle.max_isometric_force.Text);
        end
    end
end
end

function contactSurface = parseContactSurface(tree)

contactSurface.isLeftFoot = getFieldByNameOrError(tree, "is_left_foot").Text == "true";
contactSurface.beltSpeed = str2double(getFieldByNameOrError(tree, "belt_speed").Text);

contactSurface.forceColumns = parseSpaceSeparatedList(tree, "force_columns");
contactSurface.momentColumns = parseSpaceSeparatedList(tree, "moment_columns");
contactSurface.electricalCenterColumns = parseSpaceSeparatedList(tree, "electrical_center_columns");

contactSurface.toesCoordinateName = getFieldByNameOrError(tree, "toes_coordinate").Text;
contactSurface.toesJointName = getFieldByNameOrError(tree, "toes_joint").Text;

contactSurface.toeMarker = getFieldByNameOrError(tree, "toe_marker").Text;
contactSurface.medialMarker = getFieldByNameOrError(tree, "medial_marker").Text;
contactSurface.lateralMarker = getFieldByNameOrError(tree, "lateral_marker").Text;
contactSurface.heelMarker = getFieldByNameOrError(tree, "heel_marker").Text;
contactSurface.midfootSuperiorMarker = getFieldByNameOrError(tree, "midfoot_superior_marker").Text;

contactSurface.restingSpringLength = ...
    str2double(getFieldByNameOrError(tree, "resting_spring_length").Text);
contactSurface.dynamicFrictionCoefficient = ...
    str2double(getFieldByNameOrError(tree, "dynamic_friction_coefficient").Text);
contactSurface.viscousFrictionCoefficient = ...
    str2double(getFieldByNameOrError(tree, "viscous_friction_coefficient").Text);
contactSurface.dampingFactor = ...
    str2double(getFieldByNameOrError(tree, "damping_factor").Text);
contactSurface.latchingVelocity = ...
    str2double(getFieldByNameOrError(tree, "latching_velocity").Text);

gcpSpringsTree = getFieldByNameOrError(tree, "GCPSpringSet");
springsTree = getFieldByNameOrError(gcpSpringsTree, "objects").GCPSpring;
for i = 1:length(springsTree)
    if length(springsTree) == 1
        spring = springsTree;
    else
        spring = springsTree{i};
    end
    contactSurface.springs{i}.name = spring.Attributes.name;
    contactSurface.springs{i}.parentBody = getFieldByNameOrError(spring, "parent_body").Text;
    contactSurface.springs{i}.location = str2double(parseSpaceSeparatedList(spring, "location"));
    contactSurface.springs{i}.springConstant = str2double(getFieldByNameOrError(spring, "spring_constant").Text);
end
end