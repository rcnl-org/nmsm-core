
%% Kinematic Calibration Simple
import org.opensim.modeling.*
model = 'subject01_gait2392_scaled.osim';
markerfilename='walk_free_01.trc';
desiredError=0.005;
params = struct();
functions = {@(value,model)adjustChildTranslation(model, 'hip_r', 0, value), ...
    @(value,model)adjustChildTranslation(model, 'hip_r', 1, value), ...
    @(value,model)adjustChildTranslation(model, 'hip_r', 2, value)};

optimizedValues = computeKinematicCalibration(model, markerfilename, functions, desiredError, params);

assert(isvector(optimizedValues))
