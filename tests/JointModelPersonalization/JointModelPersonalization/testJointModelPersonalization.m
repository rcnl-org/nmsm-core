
%% Test translation convergence
import org.opensim.modeling.*
% model file path assumes nmsm-core project is open
inputs.model = fullfile('..','simple_arm_translated_away.osim');

% Joint parameters to optimize
task1.parameters = {
    %{jointName, isParent, isTranslation, paramNum}
    {'r_elbow', 1, 1, 0}, ... %Translation of x in the parent frame
};
task1.scaling = [];
task1.markers = [];
% Associated marker file for task 1
task1.markerFile = fullfile('..','simple_arm.trc');
% Add task to cell array of tasks as part of the input struct
inputs.tasks{1} = task1;

% Add desired error
inputs.desiredError = 0.01;

params.accuracy = 1e-6; % accuracy of the Inverse Kinematics Solver
params.display = 'iter';

newModel = JointModelPersonalization(inputs, params);
assert(isa(newModel, 'org.opensim.modeling.Model'))

frameValue = getFrameParameterValue(newModel, 'r_elbow', 1, 1, 0);
assert(abs(frameValue-0.0061)<0.0001)

%% Test orientation convergence
% model file path assumes nmsm-core project is open
inputs.model = fullfile('..','simple_arm_oriented_away.osim');

% Joint parameters to optimize
task1.parameters = {
    %{jointName, isParent, isTranslation, paramNum}
    {'r_elbow', 1, 0, 0}, ... %Orientation of x in the parent frame
};
task1.scaling = [];
task1.markers = [];

% Associated marker file for task 1
task1.markerFile = fullfile('..','simple_arm.trc');
task1.initialValues=[0.5];
task1.lowerBounds=[-0.5];
task1.upperBounds=[1.5];
% Add task to cell array of tasks as part of the input struct
inputs.tasks{1} = task1;

% Add desired error
inputs.desiredError = 0.01;

params.accuracy = 1e-6; % accuracy of the Inverse Kinematics Solver
params.display = 'iter';

newModel = JointModelPersonalization(inputs, params);
assert(isa(newModel, 'org.opensim.modeling.Model'))

frameValue = getFrameParameterValue(newModel, 'r_elbow', 1, 0, 0)
assert(abs(frameValue)<0.0001)