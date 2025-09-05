% This function is part of the NMSM Pipeline, see file for full license.
%
% This function takes MTP settings files and produces relevant plots for
% the MTP runs. The function accepts up to two settings files, but works
% with just one as well. Feeding in two settings files creates individual
% plots for both settings files, and produces a plot comparing Hill-Type
% muscle model parameters from both runs (such as to compare left and right
% leg muscle model parameters).
%
% (string), (string) -> (None)

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Robert Salati                                                %
%                                                                         %
% Licensed under the Apache License, Version 2.0 (the "License");         %
% you may not use this file except in compliance with the License.        %
% You may obtain a copy of the License at                                 %
% http://www.apache.org/licenses/LICENSE-2.0.                             %
%                                                                         %
% Unless required by applicable law or agreed to in writing, software     %
% distributed under the License is distributed on an "AS IS" BASIS,       %
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or         %
% implied. See the License for the specific language governing            %
% permissions and limitations under the License.                          %
% ----------------------------------------------------------------------- %

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
% Account for older mtp versions where active and total force were not
% saved
if isfolder(fullfile(resultsDirectory, "Analysis", "activeMuscleForces"))
    plotMtpMuscleForces(resultsDirectory)
else
    plotMtpPassiveForceCurves(resultsDirectory);
end
if isfolder(fullfile(resultsDirectory, "Analysis", "passiveJointMomentsExperimental"))
    plotMtpPassiveMomentCurves(resultsDirectory);
end
end