import org.opensim.modeling.*
% model file path assumes nmsm-core project is open
inputs.model = 'subject01_gait2392_scaled.osim';

% Joint parameters to optimize
task1.parameters = {
    %{jointName, isParent, isTranslation, paramNum}
    {'hip_r', 1, 1, 0}, ... %Translation of x in the parent frame
    {'hip_r', 1, 1, 1}, ... %Translation of y in the parent frame
    {'hip_r', 1, 1, 2}, ... %Translation of z in the parent frame
};
% Associated marker file for task 1
task1.markerFile = 'walk_free_01.trc';
% Add task to cell array of tasks as part of the input struct
inputs.tasks{1} = task1;

% Add desired error
inputs.desiredError = 0.005;

params.accuracy = 1e-6; % accuracy of the Inverse Kinematics Solver
params.display = 'iter';

newModel = JointModelPersonalization(inputs, params);

assert(isa(newModel, 'org.opensim.modeling.Model'))