function data = parseOsimxFile(filename)
tree = xml2struct(filename);
mtpMuscleSetTree = getFieldByNameOrError(tree, "MTPMuscleSet");
musclesTree = getFieldByNameOrError(mtpMuscleSetTree, "objects").RCNLMuscle;
for i = 1:length(musclesTree)
    if(length(musclesTree) == 1)
        muscle = musclesTree;
    else
        muscle = musclesTree{i};
    end
    data.(muscle.Attributes.name).electromechanicalDelay = str2double(muscle.electromechanical_delay.Text);
    data.(muscle.Attributes.name).activationTimeConstant = str2double(muscle.activation_time_constant.Text);
    data.(muscle.Attributes.name).activationNonlinearityConstant = str2double(muscle.activation_nonlinearity_constant.Text);
    data.(muscle.Attributes.name).emgScaleFactor = str2double(muscle.emg_scale_factor.Text);
    data.(muscle.Attributes.name).optimalFiberLengthScaleFactor = str2double(muscle.optimal_fiber_length_scale_factor.Text);
    data.(muscle.Attributes.name).tendonSlackLengthScaleFactor = str2double(muscle.tendon_slack_length_scale_factor.Text);
    data.(muscle.Attributes.name).tendonSlackLengthScaleFactor = str2double(muscle.tendon_slack_length_scale_factor.Text);
end
end

