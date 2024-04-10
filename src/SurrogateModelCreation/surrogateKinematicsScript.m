% Model (.osim) file used in Treatment Optimization
modelFileName = fullfile("../JointModelPersonalization/RCNL_Model_UF_4_scaled_legScaling_knee_ankle.osim");

% Reference kinematics file for coordinate sampling
referenceKinematicsFile = fullfile("../preprocessing/preprocessed_right/IKData/gait_1.sto");

% Output directory name
surrogateDataDirectoryName = fullfile("surrogateData");

% Number of LHS points per time point
settings.samplePoints = 25;

% Default padding (radians) for rotational coordinate sampling
settings.angularPadding = deg2rad(10);

% Default padding (meters) for translational coordinate sampling
settings.linearPadding = 0;

% Padding ranges specific to coordinates. The deepest struct field name
% must exactly match a coordinate name in the reference kinematics file.
% 
% Example: settings.padding.hip_flexion_r = [-0.1, 0.2];
settings.padding = struct();


% End of user-defined settings

model = Model(modelFileName);
[coordinateNames, ~, referenceKinematics] = parseMotToComponents( ...
    model, org.opensim.modeling.Storage(referenceKinematicsFile));
referenceKinematics = referenceKinematics';
lhsKinematics = sampleSurrogateKinematicsFromSettings(model, ...
    referenceKinematics, coordinateNames, settings);

[~, trialName, ~] = fileparts(referenceKinematicsFile);
if ~exist(surrogateDataDirectoryName, "dir")
mkdir(surrogateDataDirectoryName);
end
if ~exist(fullfile(surrogateDataDirectoryName, "MAData"), "dir")
    mkdir(fullfile(surrogateDataDirectoryName, "MAData"));
end
if ~exist(fullfile(surrogateDataDirectoryName, "MAData", trialName), "dir")
    mkdir(fullfile(surrogateDataDirectoryName, "MAData", trialName));
end
if ~exist(fullfile(surrogateDataDirectoryName, "IKData"), "dir")
    mkdir(fullfile(surrogateDataDirectoryName, "IKData"));
end
ikFileName = fullfile(surrogateDataDirectoryName, "IKData", ...
    trialName + ".sto");
if isfile(ikFileName)
    warning("Overwriting existing kinematics file.")
    delete(ikFileName);
end
writeToSto(coordinateNames, (1 : size(lhsKinematics, 1)) * 1e-3, ...
    lhsKinematics, ikFileName);
