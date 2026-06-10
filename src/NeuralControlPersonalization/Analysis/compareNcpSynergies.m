% Compare synergy weights and commands from two NCP result folders.
% Synergies in folder2 are reordered to best match folder1 using cosine similarity.
%
% Usage:
%   compareNcpSynergies("ncpResults_dev_symmetry", "ncpResults_neg_symmetry")
%   compareNcpSynergies("ncpResults_dev_symmetry", "ncpResults_neg_symmetry", "dev", "neg-synergy")
%
% Inputs:
%   folder1, folder2 : paths to NCP results folders (each must contain synergyWeights.sto
%                      and one *_synergyCommands.sto file)
%   label1, label2   : (optional) legend labels; default to folder names

function compareNcpSynergies(folder1, folder2, label1, label2)
import org.opensim.modeling.Storage

folder1 = string(folder1);
folder2 = string(folder2);
if nargin < 3, label1 = folder1; end
if nargin < 4, label2 = folder2; end

% --- Read synergy weights (numMuscles x numSyn from storage -> transpose to numSyn x numMuscles) ---
wStorage1 = Storage(fullfile(char(folder1), "synergyWeights.sto"));
wStorage2 = Storage(fullfile(char(folder2), "synergyWeights.sto"));
muscleNames = getStorageColumnNames(wStorage1);
W1 = storageToDoubleMatrix(wStorage1)';   % (numSyn x numMuscles)
W2 = storageToDoubleMatrix(wStorage2)';

% --- Read synergy commands (numSyn x numTimePoints -> transpose to numTimePoints x numSyn) ---
cmdFile1 = findFirstStoFile(folder1, "*_synergyCommands.sto");
cmdFile2 = findFirstStoFile(folder2, "*_synergyCommands.sto");
cStorage1 = Storage(cmdFile1);
cStorage2 = Storage(cmdFile2);
C1 = storageToDoubleMatrix(cStorage1)';   % (numTimePoints x numSyn)
C2 = storageToDoubleMatrix(cStorage2)';
t1 = normalizeTime(findTimeColumn(cStorage1));
t2 = normalizeTime(findTimeColumn(cStorage2));

% --- Reorder folder2 synergies to best match folder1 ---
numSyn = size(W1, 1);
perm = matchByCosineSimilarity(W1, W2);
W2 = W2(perm, :);
C2 = C2(:, perm);

% Report cosine similarities
fprintf('Synergy cosine similarities (folder1 vs folder2) after reordering:\n');
normW1 = W1 ./ (vecnorm(W1, 2, 2) + eps);
normW2 = W2 ./ (vecnorm(W2, 2, 2) + eps);
for i = 1:numSyn
    fprintf('  Synergy %2d: %.4f\n', i, dot(normW1(i,:), normW2(i,:)));
end

% --- Split right / left leg ---
isRight = endsWith(muscleNames, '_r');
isLeft  = endsWith(muscleNames, '_l');
numSynPerLeg = numSyn / 2;
rightIdx = 1:numSynPerLeg;
leftIdx  = numSynPerLeg+1:numSyn;

% --- Plots ---
plotWeights(W1(rightIdx, isRight), W2(rightIdx, isRight), ...
    muscleNames(isRight), label1, label2, 'Right Leg Synergy Weights');

plotWeights(W1(leftIdx, isLeft), W2(leftIdx, isLeft), ...
    muscleNames(isLeft), label1, label2, 'Left Leg Synergy Weights');

plotCommands(C1, C2, t1, t2, label1, label2);
end


% -------------------------------------------------------------------------
function plotWeights(W1, W2, muscleNames, label1, label2, figTitle)
params = getPlottingParams();
numSyn = size(W1, 1);
shortNames = strrep(regexprep(muscleNames, '_[rl]$', ''), '_', ' ');

figure(Name=figTitle, Units=params.units, Position=params.figureSize);
tl = tiledlayout(numSyn, 1, TileSpacing='compact', Padding='compact');
xlabel(tl, 'Muscle', FontSize=params.axisLabelFontSize);
ylabel(tl, 'Synergy Weight', FontSize=params.axisLabelFontSize);
set(gcf, color=params.plotBackgroundColor);

for i = 1:numSyn
    nexttile(i);
    set(gca, FontSize=params.tickLabelFontSize, color=params.subplotBackgroundColor);
    b = bar([W1(i,:); W2(i,:)]');
    b(1).FaceColor = params.lineColors(1);
    b(2).FaceColor = params.lineColors(2);
    xticks(1:numel(muscleNames));
    if i == numSyn
        xticklabels(shortNames);
        xtickangle(45);
    else
        xticklabels({});
    end
    title(sprintf('Synergy %d', i), FontSize=params.subplotTitleFontSize);
    if i == 1
        legend([label1, label2], FontSize=params.legendFontSize, Interpreter='none');
    end
    ymax = max([W1(i,:), W2(i,:)], [], 'all');
    ylim([0, max(ymax * 1.1, eps)]);
end
end


% -------------------------------------------------------------------------
function plotCommands(C1, C2, t1, t2, label1, label2)
params = getPlottingParams();
numSyn = size(C1, 2);
nCols = ceil(sqrt(numSyn));
nRows = ceil(numSyn / nCols);

figure(Name='Synergy Commands', Units=params.units, Position=params.figureSize);
tl = tiledlayout(nRows, nCols, TileSpacing='compact', Padding='compact');
xlabel(tl, 'Percent Movement [0-100%]', FontSize=params.axisLabelFontSize);
ylabel(tl, 'Synergy Command', FontSize=params.axisLabelFontSize);
set(gcf, color=params.plotBackgroundColor);

allMax = max([C1(:); C2(:)]);
for i = 1:numSyn
    nexttile(i);
    set(gca, FontSize=params.tickLabelFontSize, color=params.subplotBackgroundColor);
    hold on;
    plot(t1*100, C1(:,i), LineWidth=params.linewidth, Color=params.lineColors(1));
    plot(t2*100, C2(:,i), LineWidth=params.linewidth, Color=params.lineColors(2));
    hold off;
    title(sprintf('Synergy %d', i), FontSize=params.subplotTitleFontSize);
    if i == 1
        legend([label1, label2], FontSize=params.legendFontSize, Interpreter='none');
    end
    xlim('tight');
    ylim([0, max(allMax * 1.1, eps)]);
end
end


% -------------------------------------------------------------------------
function perm = matchByCosineSimilarity(W1, W2)
numSyn = size(W1, 1);
normW1 = W1 ./ (vecnorm(W1, 2, 2) + eps);
normW2 = W2 ./ (vecnorm(W2, 2, 2) + eps);
costMat = -normW1 * normW2';   % minimize negative cosine = maximize cosine
pairs = matchpairs(costMat, 1e9);
perm = zeros(1, numSyn);
for p = 1:size(pairs, 1)
    perm(pairs(p,1)) = pairs(p,2);
end
end


% -------------------------------------------------------------------------
function t = normalizeTime(t)
t = (t - t(1)) / (t(end) - t(1));
end


% -------------------------------------------------------------------------
function filePath = findFirstStoFile(folder, pattern)
listing = dir(fullfile(char(folder), char(pattern)));
if isempty(listing)
    error('compareNcpSynergies:fileNotFound', ...
        'No file matching "%s" found in:\n  %s', pattern, folder);
end
filePath = fullfile(listing(1).folder, listing(1).name);
end
