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

function reportNeuralControlPersonalizationResults(x,params)

nPts = params.nPts;
numMuscles = params.numMuscles;
nJoints = params.nJoints;
lMTVals = params.lMTVals;
vMTVals = params.vMTVals;
rVals = params.rVals;
IDmomentVals = params.IDmomentVals;
MuscNames = params.MuscNames;
CoordLabels = params.CoordLabels;

% Save solution
savefilename = params.savefilename;
if not(isfolder(fullfile(pwd, "result")))
    mkdir(fullfile(pwd, "result"))
end
save(fullfile(pwd, 'result', savefilename + ".mat"),'x');

% Reconstruct activation values
aVals = calcActivationsFromSynergyDesignVariables(x,params);

% Calculate muscle-tendon forces from optimal activations
for i5 = 1:nPts
    for k2 = 1:params.numMuscles
        [FMTVals(i5,k2),FTPassive(i5,k2)] = calcMuscleTendonForce(aVals(i5,k2),lMTVals(i5,k2),vMTVals(i5,k2),k2,params);
    end
end

fprintf('Maximum estimated muscle activation is %f\n', max(max(aVals)));

% Plot activations and musce-ltendon forces
plotMuscleActivations(aVals,MuscNames,params)
% plotMuscleForces(FMTVals,MuscNames,params) % can be added

% Plot joint torque results
muscleJointMoments = zeros(nPts,nJoints);
% muscleJointMoments = calcMuscleJointMoments(experimentalData, ...
%     muscleActivations, normalizedFiberLength, normalizedFiberVelocity);
% net moment
for i = 1:nPts
    for j = 1:nJoints
        for k = 1:numMuscles
            FMT = calcMuscleTendonForce(aVals(i,k),lMTVals(i,k),vMTVals(i,k),k,params);
            r = rVals(i,k,j);
            muscleJointMoments(i,j) = muscleJointMoments(i,j) + r*FMT;
        end
    end
end

plotTorques(IDmomentVals,muscleJointMoments,CoordLabels,params)

% plot synergy variables
[C,W] = unpackDesignVariables(x,params);
plotSynergies(C,W,params);

end

%--------------------------------------------------------------------------
function plotMuscleActivations(aVals,MuscLabels,params)

numMuscles_legs = params.numMuscles_legs; numMuscles_trunk = params.numMuscles_trunk; nPts = params.nPts;
EMGact_all = params.EMGact_all;
% Plot activation results
NCPtimePercent = params.NCPtimePercent;
rightLegMuscleIndices = 1:numMuscles_legs/2;
leftLegMuscleIndices = numMuscles_legs/2 + 1:numMuscles_legs;
rightTrunkMuscleIndices = numMuscles_legs + 1 : numMuscles_legs + numMuscles_trunk/2;
leftTrunkMuscleIndices = numMuscles_legs + numMuscles_trunk/2 + 1 : numMuscles_legs + numMuscles_trunk;
if ~isempty(aVals)
    figure('Name','Right Leg Activations');
    for i = rightLegMuscleIndices
        subplot(5,9,i), plot(NCPtimePercent,aVals(:,i)); hold all;
        plot(NCPtimePercent,EMGact_all(:,i));
        title(sprintf('%s', MuscLabels{i}))
        axis([0 100 0 1])
        if rem(i,9) == 1
            ylabel('Activation');
        end
        if i == 9
            legend('NCP','EMG')
        end
    end
    % title('Right Leg')
    figure('Name','Left Leg Activations');
    for i =leftLegMuscleIndices
        subplot(5,9,i-rightLegMuscleIndices(end)), plot(NCPtimePercent,aVals(:,i)); hold all;
        plot(NCPtimePercent,EMGact_all(:,i));
        title(sprintf('%s', MuscLabels{i}))
        axis([0 100 0 1])
        if rem(i,9) == 1
            ylabel('Activation');
        end
        if i == 54
            legend('NCP','EMG')
        end
    end
    % title('Left Leg')
    figure('Name','Right Trunk Activations');
    for i = rightTrunkMuscleIndices
        subplot(5,9,i-leftLegMuscleIndices(end)), plot(NCPtimePercent,aVals(:,i)); hold all;
        title(sprintf('%s', MuscLabels{i}))
        axis([0 100 0 1])
        if rem(i,9) == 1
            ylabel('Activation');
        end
    end
    % title('Right Trunk')
    figure('Name','Left Trunk Activations');
    for i = leftTrunkMuscleIndices
        subplot(5,9,i-rightTrunkMuscleIndices(end)), plot(NCPtimePercent,aVals(:,i)); hold all;
        title(sprintf('%s', MuscLabels{i}))
        axis([0 100 0 1])
        if rem(i,9) == 1
            ylabel('Activation');
        end
    end
end
end
%--------------------------------------------------------------------------
function plotTorques(IDmomentVals,torqueVals,jointNames,params)

nJoints = params.nJoints; NCPtimePercent = params.NCPtimePercent;

figure;

for i = 1:nJoints
    subplot(4,4,i), plot(NCPtimePercent,IDmomentVals(:,i),'k-',NCPtimePercent,torqueVals(:,i)); hold all
    if rem(i,4) == 1
        ylabel('Joint Torque (Nm)');
    end
    title(jointNames{i})

    if i == 4
        legend('ID','NCP');
    end

end
end

%--------------------------------------------------------------------------
function plotSynergies(C,W,params) % to be tidied up
% C: synergy curves
% W: synergy weights
numSynergies = params.numSynergies;
numMuscles = params.numMuscles;
MuscNames = params.MuscNames;
nPts = params.nPts;
y_lim = [0,0.1];

colors_old = [[0, 0, 1]; [0, 0.5, 0]; [1, 0, 0]; [0, 0.75, 0.75]; [0.75, 0, 0.75]; [0.75, 0.75, 0]; [0.25, 0.25, 0.25]];
colors_new = [[0, 0.4470, 0.7410]; [0.8500, 0.3250, 0.0980]; [0.9290, 0.6940, 0.1250]; [0.4940, 0.1840, 0.5560]; [0.4660, 0.6740, 0.1880]; [0.3010, 0.7450, 0.9330]; [0.6350, 0.0780, 0.1840]];
colors_all = [colors_old; colors_new];

%% Right Leg Weights

h=figure; set(h,'units','normalized','outerposition',[0 0 1/4 1]);

for i=1:6

    subplot(7,1,i)
    set(gca,'fontsize',18)

    bar(W(i,:),0.5,'FaceColor',colors_all(i,:));hold all

    xlim([0,numMuscles/2+1])
    ylim(y_lim)

    box on; grid off;
    set(gca,'XTick',1:numMuscles/2);
    if i == numSynergies/2
        set(gca, 'XTickLabel', MuscNames);
    else
        set(gca, 'XTickLabel', []);
    end
    xtickangle(90);
    title(['V' num2str(i) '-right'])
end

size_plt = get(gcf,'Position').*get(gcf,'PaperPosition'); width = size_plt(3); height = size_plt(4);

%% Left Leg Weights
h=figure; set(h,'units','normalized','outerposition',[0 0 1/4 1]);

for i=7:12

    subplot(7,1,i-6)
    set(gca,'fontsize',18)

    bar(W(i,:),0.5,'FaceColor',colors_all(i,:));hold all

    xlim([0,numMuscles/2+1])
    ylim(y_lim)

    box on; grid off;
    set(gca,'XTick',1:numMuscles/2);
    if i == 12
        set(gca, 'XTickLabel', MuscNames);
    else
        set(gca, 'XTickLabel', []);
    end
    xtickangle(90);
    title(['V' num2str(i) '-left'])
end

size_plt = get(gcf,'Position').*get(gcf,'PaperPosition'); width = size_plt(3); height = size_plt(4);

%% Right Commands
h=figure;
set(h,'units','normalized','outerposition',[0 0 1/2 1]);
idx={'1','2','3','4','5','6'};
idx=0;
idx = idx+1;
for i=1:numSynergies/2

    %subplot(Nsub,NofSyn,i+NofSyn*(j-1))
    subplot(numSynergies/2,1,i)
    %             subplot(plot_sub_no,NofSyn,i+(j-1-(kkk-1)*plot_sub_no)*NofSyn);
    set(gca,'fontsize',24)

    plot(0:1:nPts-1,C(:,i),'color',colors_all(i,:),'LineWidth',2);

    set(gca,'Ylim',[0 inf])
    set(gca,'Xlim',[0 nPts-1])
    box on; grid off;


    title(['C' num2str(i) '- right']);



    if i~=6
        set(gca,'XTickLabel',[])
    end

    ylim([-1,ceil(max(C(:)))]);
end


size_plt = get(gcf,'OuterPosition').*get(gcf,'PaperPosition'); width = size_plt(3); height = size_plt(4);

%% Left Commands
h=figure;
set(h,'units','normalized','outerposition',[0 0 1/2 1]);
idx={'1','2','3','4','5','6'};
idx=0;
idx = idx+1;
for i=1:numSynergies/2

    subplot(numSynergies/2,1,i)
    set(gca,'fontsize',24)

    plot(0:1:nPts-1,C(:,i+6),'color',colors_all(i+6,:),'LineWidth',2);

    set(gca,'Ylim',[0 inf])
    set(gca,'Xlim',[0 nPts-1])
    box on; grid off;


    title(['C' num2str(i) '- left']);



    if i~=6
        set(gca,'XTickLabel',[])
    end

    ylim([-1,ceil(max(C(:)))]);
end


size_plt = get(gcf,'OuterPosition').*get(gcf,'PaperPosition'); width = size_plt(3); height = size_plt(4);
end