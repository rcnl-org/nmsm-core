clear

tic
[inputs, params, resultsDirectory] = ...
    parseGroundContactPersonalizationSettingsTree(...
    xml2struct("GCP_settings.xml"));
inputs = prepareGroundContactPersonalizationInputs(inputs);

% Stage 0
if params.restingSpringLengthInitialization
    inputs = initializeRestingSpringLength(inputs);
end
% inputs = load('1-29-extramarkercol-0_1std_1000mae-1e-4damping-02moment_1', 'inputs');
% inputs = inputs.inputs;

for task = 1:length(inputs.tasks)
    inputs.tasks{task}.experimentalGroundReactionMoments = ...
        replaceMomentsAboutMidfootSuperior(inputs.tasks{task}, inputs);
    inputs.tasks{task}.experimentalGroundReactionMomentsSlope = ...
        calcBSplineDerivative(inputs.tasks{task}.time, ...
        inputs.tasks{task}.experimentalGroundReactionMoments, 2, ...
        inputs.tasks{task}.splineNodes);
end

% GCP Tasks
for task = 1:length(params.tasks)
    inputs = optimizeGroundContactPersonalizationTask(inputs, params, task);
    save("3-15-YXZ_" + task + ".mat")
end
toc

%% Save results to osimx
saveGroundContactPersonalizationResults(inputs, params, pwd)

%% Plot forces and kinematics
for foot = 1:length(inputs.tasks)
    figure(1 + 3 * (foot - 1))
    plotGroundReactionQuantities(inputs, params, task, foot)
    figure(2 + 3 * (foot - 1))
    plotCoordinates(inputs.tasks{foot})
end

%% Spring constant plot
% footModel = Model("footModel.osim");
for foot = 1:length(inputs.tasks)
    figure(3 + 3 * (foot - 1))
    plotSpringConstants(inputs.tasks{foot}, inputs)
end

%% Replace moments

% (struct) -> (2D Array of double)
% Replace parsed experimental ground reaction moments about midfoot
% superior marker projected onto floor
function replacedMoments = replaceMomentsAboutMidfootSuperior(task, inputs)
    replacedMoments = ...
        zeros(size(task.experimentalGroundReactionMoments));
    for i = 1:size(replacedMoments, 2)
        newCenter = task.midfootSuperiorPosition(:, i);
        newCenter(2) = inputs.restingSpringLength;
        replacedMoments(:, i) = ...
            task.experimentalGroundReactionMoments(:, i) + ...
            cross((task.electricalCenter(:, i) - newCenter), ...
            task.experimentalGroundReactionForces(:, i));
    end
end
