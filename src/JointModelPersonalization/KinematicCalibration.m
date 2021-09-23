% Kinematic Calibration takes a model and applies a calibration.

% Copyright RCNL *change*

% (Model, Array, Array, struct) -> (Model)
% Creates calibrated model from joint structure and marker plate structure
function outputModel = KinematicCalibration(inputModel, jointArray, ...
    markerPlateArray, params)
% Prepare optimizer
outputModel = Model() % Setup OpenSim Model
optimizations = orderOptimizations(optimizations) % Determine Optimization Order
% Run Optimization in order specified (could put for-loop here)
for i=1:length(optimizations)
   outputModel = computeInnerOptimization(outputModel, optimizations(i)) 
end
end