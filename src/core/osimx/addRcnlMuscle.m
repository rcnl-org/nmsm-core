function osimx = addRcnlMuscle(osimx, muscleName, muscleParameters)

muscleObjects = osimx.NMSMPipelineDocument.OsimxModel.RCNLMuscleSet.objects;

if(~isstruct(muscleObjects))
    i = 1;
    muscleObjects.RCNLMuscle = {};
else
    i = length(muscleObjects.RCNLMuscle) + 1;
end

muscles = muscleObjects.RCNLMuscle;
muscles{i}.Attributes.name = convertStringsToChars(muscleName);

muscles{i}.electromechanical_delay.Comment = 'Optimized electromechanical delay';
muscles{i}.electromechanical_delay.Text = convertStringsToChars( ...
    num2str(muscleParameters.electromechanicalDelay, 15));

muscles{i}.activation_time_constant.Comment = 'Optimized activation time constant';
muscles{i}.activation_time_constant.Text = convertStringsToChars( ...
    num2str(muscleParameters.activationTimeConstant, 15));

muscles{i}.activation_nonlinearity_constant.Comment = 'Optimized activation nonlinearity constant';
muscles{i}.activation_nonlinearity_constant.Text = convertStringsToChars( ...
    num2str(muscleParameters.activationNonlinearityConstant, 15));

muscles{i}.emg_scale_factor.Comment = 'Optimized EMG scale factor';
muscles{i}.emg_scale_factor.Text = convertStringsToChars( ...
    num2str(muscleParameters.emgScaleFactor, 15));

muscles{i}.optimal_fiber_length.Comment = 'Optimized optimal fiber length';
muscles{i}.optimal_fiber_length.Text = convertStringsToChars( ...
    num2str(muscleParameters.optimalFiberLength, 15));

muscles{i}.tendon_slack_length.Comment = 'Optimized tendon slack length';
muscles{i}.tendon_slack_length.Text = convertStringsToChars( ...
    num2str(muscleParameters.tendonSlackLength, 15));

osimx.NMSMPipelineDocument.OsimxModel.RCNLMuscleSet.objects.RCNLMuscle = muscles;

end

