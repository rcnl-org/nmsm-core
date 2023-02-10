clear

[inputs, params] = parseGroundContactPersonalizationSettingsTree(...
    xml2struct("GCP_settings_tasklist.xml"));
inputs = prepareGroundContactPersonalizationInputs(inputs);

% Stage 0
inputs = initializeRestingSpringLength(inputs, params);
% inputs = load('1-29-extramarkercol-0_1std_1000mae-1e-4damping-02moment_1', 'inputs');
% inputs = inputs.inputs;

for task = 1:length(params.tasks)
    params.tasks{task}.costTerms.springConstantErrorFromNeighbors.standardDeviation = valueOrAlternate(params, 'nothere', 0.05);
end

% GCP Tasks
for task = 1:length(params.tasks)
    inputs = optimizeGroundContactPersonalizationTask(inputs, params, task);
    save("2-6-4deg01m_" + task + ".mat")
end

%% Plot forces and kinematics
if exist('1', 'var')
    close 1
end
if exist('2', 'var')
    close 2
end
figure(1)
plotGroundReactionQuantities(inputs, params, task)
figure(2)
plotCoordinates(inputs)

%% Spring constant plot
if exist('3', 'var')
    close 3
end
figure(3)
footModel = Model("footModel.osim");
plotSpringConstants(footModel, inputs, inputs.toesBodyName, inputs.hindfootBodyName)

%% Report cost quantities

% [modeledJointPositions, modeledJointVelocities] = calcGCPJointKinematics( ...
%     inputs.experimentalJointPositions, inputs.jointKinematicsBSplines, ...
%     inputs.bSplineCoefficients);
% modeledValues = calcGCPModeledValues(inputs, inputs, ...
%     modeledJointPositions, modeledJointVelocities, params, task);
% modeledValues.jointPositions = modeledJointPositions;
% modeledValues.jointVelocities = modeledJointVelocities;
% 
% disp('Unweighted Vertical GRF Cost: ')
% [groundReactionForceValueError, ~] = ...
%     calcVerticalGroundReactionForceAndSlopeError(inputs, ...
%     modeledValues);
% disp(sum(abs(groundReactionForceValueError)))
% if lastStage >= 2
%     [groundReactionForceValueErrors, ~] = ...
%         calcGroundReactionForceAndSlopeError(inputs, modeledValues);
%     disp('Unweighted Anterior GRF Cost: ')
%     disp(sum(abs(groundReactionForceValueErrors(1, :))))
%     disp('Unweighted Lateral GRF Cost: ')
%     disp(sum(abs(groundReactionForceValueErrors(3, :))))
% end
% if lastStage == 3
%     [groundReactionMomentErrors, ~] = ...
%         calcGroundReactionMomentAndSlopeError(inputs, modeledValues);
%     disp('Unweighted Moment Cost: ')
%     disp(sum(abs(groundReactionMomentErrors), 'all'))
% end
% disp('Unweighted Marker Tracking Cost: ')
% [footMarkerPositionError, ~] = ...
%     calcFootMarkerPositionAndSlopeError(inputs, modeledValues);
% disp(sum(abs(footMarkerPositionError)))
