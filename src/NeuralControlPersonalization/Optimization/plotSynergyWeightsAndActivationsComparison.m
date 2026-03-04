function plotSynergyWeightsAndActivationsComparison(initialValues, finalValues, inputs)

    [W0, ~,C0] = findSynergyWeightsAndCommands(initialValues, inputs);
    [W1, ~,C1] = findSynergyWeightsAndCommands(finalValues,  inputs);

    [W0, C0] = normalizeSynergiesByMaximumWeight(W0, C0);
    [W1, C1] = normalizeSynergiesByMaximumWeight(W1, C1);

    [nSyn, nMus] = size(W0);
    muscleNames  = collectMuscleNames(inputs.synergyGroups);
    baseNames    = stripSidePostfix(muscleNames);

    nMusHalf = floor(nMus/2);
    idxRmus  = 1:nMusHalf;
    idxLmus  = nMusHalf+1:nMus;

    nSynHalf = floor(nSyn/2);

    plotWeightsTiled(W0, W1, baseNames, idxRmus, idxLmus, nSynHalf);
    plotActivationsTiled(C0, C1, nSynHalf);

end

% ======================== helpers ========================

function names = collectMuscleNames(synergyGroups)
    names = {};
    for g = 1:numel(synergyGroups)
        names = [names, synergyGroups{g}.muscleNames]; %#ok<AGROW>
    end
end

function base = stripSidePostfix(names)
    base = regexprep(names, '(_[RrLl])$', '');
end

function plotWeightsTiled(W0, W1, baseNames, idxRmus, idxLmus, nSynHalf)

    fig = figure('Color','w');
    tiledlayout(nSynHalf, 2, 'TileSpacing','compact','Padding','compact');

    hBar = []; hLine = [];

    for s = 1:nSynHalf
        % right
        ax = nexttile; hold(ax,'on');
        [b,l] = plotWeightPanel(ax, W0(s, idxRmus), W1(s, idxRmus), baseNames(idxRmus), ...
            sprintf('Right synergy %d', s), s == nSynHalf);
        if isempty(hBar),  hBar  = b; end
        if isempty(hLine), hLine = l; end

        % left
        ax = nexttile; hold(ax,'on');
        rowL = s + nSynHalf;
        plotWeightPanel(ax, W0(rowL, idxLmus), W1(rowL, idxLmus), baseNames(idxLmus), ...
            sprintf('Left synergy %d', s), s == nSynHalf);
    end

    % Legend: attach to figure/axes using explicit handles (compatible)
    if ~isempty(hBar) && ~isempty(hLine)
        legend([hBar, hLine], {'Optimized','Initial'}, 'Location','bestoutside');
    end

    sgtitle('Init vs Optimized synergy weights (Right vs Left)');
    drawnow;

end

function [b, l] = plotWeightPanel(ax, wInit, wFinal, labels, ttl, showXLabels)

    b = bar(ax, wFinal);                       % optimized
    b.FaceColor = "#4477AA";
    l = plot(ax, wInit, 'LineWidth', 1.5, 'Color', "#EE6677"); % initial
    yline(ax, 0, 'Color', [0.3 0.3 0.3], 'LineWidth', 1.0);

    title(ax, ttl);
    ylabel(ax, 'Weight');
    xlim(ax, [1 numel(wFinal)]);
    ylim(ax, [-1, 1]);

    set(ax, 'XTick', 1:numel(wFinal));
    if showXLabels
        set(ax, 'XTickLabel', labels);
        xtickangle(ax, 45);
        xlabel(ax, 'Muscle index');
    else
        set(ax, 'XTickLabel', []);
    end

    grid(ax, 'on');
    ax.Layer = 'top';
    box(ax, 'on');

end

function plotActivationsTiled(C0, C1, nSynHalf)

    figure('Color','w');
    tiledlayout(nSynHalf, 2, 'TileSpacing','compact','Padding','compact');

    nTime = min(size(C0,2), size(C1,2));
    t = 1:nTime;

    hInit = []; hOpt = [];

    for s = 1:nSynHalf
        ax = nexttile; hold(ax,'on');
        [hi, ho] = plotActivationPanel(ax, t, C0(1,1:nTime,s), C1(1,1:nTime,s), sprintf('Right activation %d', s));
        if isempty(hInit), hInit = hi; end
        if isempty(hOpt),  hOpt  = ho; end

        ax = nexttile; hold(ax,'on');
        rowL = s + nSynHalf;
        plotActivationPanel(ax, t, C0(1,1:nTime,rowL), C1(1,1:nTime,rowL), sprintf('Left activation %d', s));
    end

    if ~isempty(hInit) && ~isempty(hOpt)
        legend([hInit, hOpt], {'Initial','Optimized'}, 'Location','bestoutside');
    end

    sgtitle('Init vs Optimized synergy activations (Right vs Left)');
    drawnow;

end

function [hInit, hOpt] = plotActivationPanel(ax, t, cInit, cOpt, ttl)

    hInit = plot(ax, t, cInit, 'LineWidth', 1.2); % default color
    hOpt  = plot(ax, t, cOpt,  'LineWidth', 1.2); % default color
    yline(ax, 0, 'Color', [0.85 0.85 0.85]);

    title(ax, ttl);
    xlabel(ax, 'Time index');
    ylabel(ax, 'Activation');
    xlim(ax, [t(1) t(end)]);
    grid(ax, 'on');
    ax.Layer = 'top';
    box(ax, 'on');

end
