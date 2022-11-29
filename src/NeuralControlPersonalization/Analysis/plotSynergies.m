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

    plot(0:1:inputs.numPoints - 1, C(:, i), 'color', colors_all(i, :), 'LineWidth', 2);

    set(gca, 'Ylim', [0 inf])
    set(gca, 'Xlim', [0 inputs.numPoints - 1])
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

    plot(0:1:inputs.numPoints - 1, C(:, i + 6), 'color', colors_all(i + 6, :), 'LineWidth', 2);

    set(gca, 'Ylim', [0 inf])
    set(gca, 'Xlim', [0 inputs.numPoints - 1])
    box on; grid off;

    title(['C' num2str(i) '- left']);

    if i ~= 6
        set(gca, 'XTickLabel', [])
    end

    ylim([-1, ceil(max(C(:)))]);
end

size_plt = get(gcf, 'OuterPosition') .* get(gcf, 'PaperPosition'); width = size_plt(3); height = size_plt(4);
end