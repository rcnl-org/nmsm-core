settingsFileName = "newMTPSettingsFile.xml";
settingsTree = xml2struct(settingsFileName);
[inputs, params, resultsDirectory] = parseMuscleTendonPersonalizationSettingsTree(settingsTree);

% MuscleTendonPersonalizationTool(settingsFileName)

% import org.opensim.modeling.Storage
%
% passiveData = load("thelen/passiveData.mat").passiveData;
%
% size(passiveMomentsArms)
%
% size(passiveData.inverseDynamicsMoments)
%
%
%
% prefixes = findPrefixes(struct(), fullfile(pwd, "thelen"));
% momentNames = parseMotToComponents(Model("model.osim"), ...
%     Storage(fullfile(pwd, "thelen", "IKData", "Thelen_AnklePassive_01.mot")))
% muscleNames = parseMotToComponents(Model("model.osim"), ...
%     Storage(fullfile(pwd, "MAData", "speed2_squat_1", "speed2_squat_1_MomentArm_hip_adduction_l.sto")))
% for i=1:length(prefixes)
%     if ~exist(fullfile(pwd, "thelen", "MAData", prefixes(i)), 'dir')
%         mkdir(fullfile(pwd, "thelen", "MAData", prefixes(i)))
%     end
%     for j=1:length(momentNames)
%         writeToSto(muscleNames, linspace(0,1,101), ...
%             squeeze(passiveMomentsArms(i, j, :, :))', ...
%             fullfile(pwd, "thelen", "MAData", prefixes(i), prefixes(i) + "_MomentArm_" + momentNames(j) + ".sto"))
%     end
%     writeToSto(muscleNames, linspace(0,1,101), ...
%             squeeze(passiveMuscleTendonLength(i, :, :))', ...
%             fullfile(pwd, "thelen", "MAData", prefixes(i), prefixes(i) + "_Length.sto"))
% end


