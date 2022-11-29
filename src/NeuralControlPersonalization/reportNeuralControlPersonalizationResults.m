% function reportNeuralControlPersonalizationResults(settingsFileName)
% settingsTree = xml2struct(settingsFileName);
% [inputs, params, resultsDirectory] = ...
%     parseNeuralControlPersonalizationSettingsTree(settingsTree);
% optimizedParams = NeuralControlPersonalization(inputs, params);
% %% results is a structure, report not implemented yet
% results = calcFinalMuscleActivations(optimizedParams, inputs);
% results = calcFinalModelMoments(results, inputs);
% save("results.mat", "results", '-mat')
% % reportNeuralControlPersonalization(inputs.model, results)
% saveNeuralControlPersonalizationResults(inputs.model, ...
%     inputs.coordinates, results, resultsDirectory);

function reportNeuralControlPersonalizationResults(x, inputs, params)

CoordLabels = inputs.CoordLabels;

% Save solution
savefilename = inputs.savefilename;

if not(isfolder(fullfile(pwd, "result")))
    mkdir(fullfile(pwd, "result"))
end
save(fullfile(pwd, 'result', savefilename + ".mat"), 'x');

% Reconstruct activation values
aVals = calcActivationsFromSynergyDesignVariables(x, inputs, params);

% Calculate muscle-tendon forces from optimal activations
for i5 = 1:inputs.nPts
    for k2 = 1:inputs.numMuscles
        [FMTVals(i5, k2), FTPassive(i5, k2)] = calcMuscleTendonForce(aVals(i5, k2), inputs.muscleTendonLength(i5, k2), inputs.muscleTendonVelocity(i5, k2), k2, inputs);
    end
end

fprintf('Maximum estimated muscle activation is %f\n', max(max(aVals)));

% Plot activations and musce-ltendon forces
plotMuscleActivations(aVals, inputs.MuscNames, inputs)
% plotMuscleForces(FMTVals, inputs.MuscNames,inputs) % can be added

% Plot joint torque results
muscleJointMoments = zeros(inputs.nPts, inputs.nJoints);
% net moment
for i = 1:inputs.nPts
    for j = 1:inputs.nJoints
        for k = 1:inputs.numMuscles
            FMT = calcMuscleTendonForce(aVals(i, k), inputs.muscleTendonLength(i, k), inputs.muscleTendonVelocity(i, k), k, inputs);
            r = inputs.rVals(i, k, j);
            muscleJointMoments(i, j) = muscleJointMoments(i, j) + r * FMT;
        end

    end

end

plotTorques(muscleJointMoments, CoordLabels, inputs)

% plot synergy variables
[C, W] = unpackDesignVariables(x, inputs, params);
plotSynergies(C, W, inputs);

end

%--------------------------------------------------------------------------


%--------------------------------------------------------------------------
function plotTorques(torqueVals, jointNames, inputs, params)

figure;

for i = 1:inputs.nJoints
    subplot(4, 4, i), plot(inputs.NCPtimePercent, inputs.IDmomentVals(:, i), 'k-', inputs.NCPtimePercent, torqueVals(:, i)); hold all

    if rem(i, 4) == 1
        ylabel('Joint Torque (Nm)');
    end

    title(jointNames{i})

    if i == 4
        legend('ID', 'NCP');
    end

end

end

%--------------------------------------------------------------------------
function plotSynergies(C, W, inputs, params) % to be tidied up
% C: synergy curves
% W: synergy weights
numSynergies = inputs.numSynergies;
y_lim = [0, 0.1];

colors_old = [[0, 0, 1]; [0, 0.5, 0]; [1, 0, 0]; [0, 0.75, 0.75]; [0.75, 0, 0.75]; [0.75, 0.75, 0]; [0.25, 0.25, 0.25]];
colors_new = [[0, 0.4470, 0.7410]; [0.8500, 0.3250, 0.0980]; [0.9290, 0.6940, 0.1250]; [0.4940, 0.1840, 0.5560]; [0.4660, 0.6740, 0.1880]; [0.3010, 0.7450, 0.9330]; [0.6350, 0.0780, 0.1840]];
colors_all = [colors_old; colors_new];

%% Right Leg Weights

h = figure; set(h, 'units', 'normalized', 'outerposition', [0 0 1/4 1]);

for i = 1:6

    subplot(7, 1, i)
    set(gca, 'fontsize', 18)

    bar(W(i, :), 0.5, 'FaceColor', colors_all(i, :)); hold all

    xlim([0, inputs.numMuscles / 2 + 1])
    ylim(y_lim)

    box on; grid off;
    set(gca, 'XTick', 1:inputs.numMuscles / 2);

    if i == numSynergies / 2
        set(gca, 'XTickLabel', inputs.MuscNames);
    else
        set(gca, 'XTickLabel', []);
    end

    xtickangle(90);
    title(['V' num2str(i) '-right'])
end

size_plt = get(gcf, 'Position') .* get(gcf, 'PaperPosition'); width = size_plt(3); height = size_plt(4);

%% Left Leg Weights
h = figure; set(h, 'units', 'normalized', 'outerposition', [0 0 1/4 1]);

for i = 7:12

    subplot(7, 1, i - 6)
    set(gca, 'fontsize', 18)

    bar(W(i, :), 0.5, 'FaceColor', colors_all(i, :)); hold all

    xlim([0, inputs.numMuscles / 2 + 1])
    ylim(y_lim)

    box on; grid off;
    set(gca, 'XTick', 1:inputs.numMuscles / 2);

    if i == 12
        set(gca, 'XTickLabel', inputs.MuscNames);
    else
        set(gca, 'XTickLabel', []);
    end

    xtickangle(90);
    title(['V' num2str(i) '-left'])
end

size_plt = get(gcf, 'Position') .* get(gcf, 'PaperPosition'); width = size_plt(3); height = size_plt(4);

%% Right Commands
h = figure;
set(h, 'units', 'normalized', 'outerposition', [0 0 1/2 1]);
idx = {'1', '2', '3', '4', '5', '6'};
idx = 0;
idx = idx + 1;

for i = 1:numSynergies / 2

    %subplot(Nsub,NofSyn,i+NofSyn*(j-1))
    subplot(numSynergies / 2, 1, i)
    %             subplot(plot_sub_no,NofSyn,i+(j-1-(kkk-1)*plot_sub_no)*NofSyn);
    set(gca, 'fontsize', 24)

    plot(0:1:inputs.nPts - 1, C(:, i), 'color', colors_all(i, :), 'LineWidth', 2);

    set(gca, 'Ylim', [0 inf])
    set(gca, 'Xlim', [0 inputs.nPts - 1])
    box on; grid off;

    title(['C' num2str(i) '- right']);

    if i ~= 6
        set(gca, 'XTickLabel', [])
    end

    ylim([-1, ceil(max(C(:)))]);
end

size_plt = get(gcf, 'OuterPosition') .* get(gcf, 'PaperPosition'); width = size_plt(3); height = size_plt(4);

%% Left Commands
h = figure;
set(h, 'units', 'normalized', 'outerposition', [0 0 1/2 1]);
idx = {'1', '2', '3', '4', '5', '6'};
idx = 0;
idx = idx + 1;

for i = 1:numSynergies / 2

    subplot(numSynergies / 2, 1, i)
    set(gca, 'fontsize', 24)

    plot(0:1:inputs.nPts - 1, C(:, i + 6), 'color', colors_all(i + 6, :), 'LineWidth', 2);

    set(gca, 'Ylim', [0 inf])
    set(gca, 'Xlim', [0 inputs.nPts - 1])
    box on; grid off;

    title(['C' num2str(i) '- left']);

    if i ~= 6
        set(gca, 'XTickLabel', [])
    end

    ylim([-1, ceil(max(C(:)))]);
end

size_plt = get(gcf, 'OuterPosition') .* get(gcf, 'PaperPosition'); width = size_plt(3); height = size_plt(4);
end
