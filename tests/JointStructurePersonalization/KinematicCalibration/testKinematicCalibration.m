
%% Kinematic Calibration Simple
import org.opensim.modeling.*
model = fullfile('..','simple_arm_oriented_away.osim');
markerFile = fullfile('..','simple_arm.trc');
desiredError=0.01;
params.initialValues=[0.5];
functions = {
    @(value,model)adjustParentOrientation(model, 'r_elbow', 0, value)
    };

optimizedValues = computeKinematicCalibration(model, markerFile, functions, desiredError, params);

assert(isvector(optimizedValues))
