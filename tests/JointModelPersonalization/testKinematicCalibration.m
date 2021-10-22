
%% Kinematic Calibration Simple
import org.opensim.modeling.*
model = Model(strcat(pwd, '\tests\JointModelPersonalization\models\subject01_gait2392_scaled.osim'));
markerfilename=strcat(pwd, '\tests\JointModelPersonalization\trc\walk_free_01.trc');
params = struct();
functions = {@(value,model)adjustChildTranslation(model, 'hip_r', 0, value), ...
    @(value,model)adjustChildTranslation(model, 'hip_r', 1, value), ...
    @(value,model)adjustChildTranslation(model, 'hip_r', 2, value)};

newModel = computeKinematicCalibration(model, markerfilename, functions, params);

class(newModel)
class(Model())

assert(strcmp(class(newModel),class(Model())))
