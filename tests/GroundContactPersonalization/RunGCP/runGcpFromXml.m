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

for surface = 1:length(inputs.surfaces)
    inputs.surfaces{surface}.experimentalGroundReactionMoments = ...
        replaceMomentsAboutMidfootSuperior(inputs.surfaces{surface}, inputs);
    inputs.surfaces{surface}.experimentalGroundReactionMomentsSlope = ...
        calcBSplineDerivative(inputs.surfaces{surface}.time, ...
        inputs.surfaces{surface}.experimentalGroundReactionMoments, 2, ...
        inputs.surfaces{surface}.splineNodes);
end

% GCP Tasks
for task = 1:length(params.tasks)
    inputs = optimizeGroundContactPersonalizationTask(inputs, params, task);
    save("4-5-newCostStructure_" + task + ".mat")
end
toc

%% Save results to osimx
saveGroundContactPersonalizationResults(inputs, params, pwd)

%% Plot forces and kinematics
for foot = 1:length(inputs.surfaces)
    figure(1 + 3 * (foot - 1))
    plotGroundReactionQuantities(inputs, params, task, foot)
    figure(2 + 3 * (foot - 1))
    plotCoordinates(inputs.surfaces{foot})
end

%% Spring constant plot
% footModel = Model("footModel.osim");
for foot = 1:length(inputs.surfaces)
    figure(3 + 3 * (foot - 1))
    plotSpringConstants(inputs.surfaces{foot}, inputs)
end

%% Replace moments

% (struct) -> (2D Array of double)
% Replace parsed experimental ground reaction moments about midfoot
% superior marker projected onto floor
function replacedMoments = replaceMomentsAboutMidfootSuperior(surface, inputs)
    replacedMoments = ...
        zeros(size(surface.experimentalGroundReactionMoments));
    for i = 1:size(replacedMoments, 2)
        newCenter = surface.midfootSuperiorPosition(:, i);
        newCenter(2) = inputs.restingSpringLength;
        replacedMoments(:, i) = ...
            surface.experimentalGroundReactionMoments(:, i) + ...
            cross((surface.electricalCenter(:, i) - newCenter), ...
            surface.experimentalGroundReactionForces(:, i));
    end
end
