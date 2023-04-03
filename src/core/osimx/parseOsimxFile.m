function osimx = parseOsimxFile(osimxFileName)

tree = xml2struct(osimxFileName);

osimx.model = getFieldByNameOrError(tree, "associated_osim_model").Text;
osimx.modelName = getFieldByNameOrError(tree, "OsimxModel").Attributes.name;

groundContactTree = getFieldByName(tree, "RCNLGroundContact");
if(isstruct(groundContactTree))
    osimx.groundContact.restingSpringLength = ...
        str2double(getFieldByNameOrError(groundContactTree, "resting_spring_length").Text);
    osimx.groundContact.dynamicFrictionCoefficient = ...
        str2double(getFieldByNameOrError(groundContactTree, "dynamic_friction_coefficient").Text);
    osimx.groundContact.dampingFactor = ...
        str2double(getFieldByNameOrError(groundContactTree, "damping_factor").Text);

    contactSurfaceTree = getFieldByNameOrError(groundContactTree, "GCPContactSurface");

    for i = 1:length(contactSurfaceTree)
        if length(contactSurfaceTree) == 1
            contactSurface = contactSurfaceTree;
        else
            contactSurface{i} = contactSurfaceTree;
        end
        osimx.groundContact.contactSurface{i} = parseContactSurface(contactSurfaceTree);
    end
end

mtpMuscleSetTree = getFieldByName(tree, "RCNLMuscleSet");
if(isstruct(mtpMuscleSetTree))
    musclesTree = getFieldByNameOrError(mtpMuscleSetTree, "objects").RCNLMuscle;

    for i = 1:length(musclesTree)
        if length(musclesTree) == 1
            muscle = musclesTree;
        else
            muscle = musclesTree{i};
        end
        osimx.muscles.(muscle.Attributes.name).electromechanicalDelay = str2double(muscle.electromechanical_delay.Text);
        osimx.muscles.(muscle.Attributes.name).activationTimeConstant = str2double(muscle.activation_time_constant.Text);
        osimx.muscles.(muscle.Attributes.name).activationNonlinearityConstant = str2double(muscle.activation_nonlinearity_constant.Text);
        osimx.muscles.(muscle.Attributes.name).emgScaleFactor = str2double(muscle.emg_scale_factor.Text);
        osimx.muscles.(muscle.Attributes.name).optimalFiberLength = str2double(muscle.optimal_fiber_length.Text);
        osimx.muscles.(muscle.Attributes.name).tendonSlackLength = str2double(muscle.tendon_slack_length.Text);
    end
end
end

function contactSurface = parseContactSurface(tree)

contactSurface.isLeftFoot = getFieldByNameOrError(tree, "is_left_foot").Text == "true";
contactSurface.toesCoordinateName = getFieldByNameOrError(tree, "toes_coordinate").Text;
contactSurface.toesJointName = getFieldByNameOrError(tree, "toes_joint").Text;

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