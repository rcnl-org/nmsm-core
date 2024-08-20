function plotMtpResultsFromSettingsFile(settingsFileName1, settingsFileName2)
import org.opensim.modeling.Storage
settingsTree1 = xml2struct(settingsFileName1);
resultsDirectory1 = getFieldByName(settingsTree1, 'results_directory').Text;
plotMtpResultsFromDirectory(resultsDirectory1)
if nargin > 1
    settingsTree2 = xml2struct(settingsFileName2);
    resultsDirectory2 = getFieldByName(settingsTree2, 'results_directory').Text;
    plotMtpResultsFromDirectory(resultsDirectory2)
    plotMtpHillTypeMuscleParamsCompare(resultsDirectory1, resultsDirectory2)
else
    plotMtpHillTypeMuscleParams(resultsDirectory1);
end
end

function plotMtpResultsFromDirectory(resultsDirectory)
    plotMtpJointMoments(resultsDirectory);
    plotMtpMuscleExcitationsAndActivations(resultsDirectory);
    plotMtpNormalizedFiberLengths(resultsDirectory);
    plotMtpPassiveForceCurves(resultsDirectory);
    plotMtpPassiveMomentCurves(resultsDirectory);
end