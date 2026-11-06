% This function is part of the NMSM Pipeline, see file for full license.
%
% This function runs OpenSim's MuscleAnalysis over a whole motion, for all
% muscles and coordinates with moment arms computed, and writes the results
% to the given directory as <motion name>_MuscleAnalysis_*.sto. The settings
% are printed to <motion name>_MuscleAnalysisSettings.xml in that directory
% and the tool is reloaded from it before running, as in the tutorial's
% passiveTrialMuscleAnalysis.m.
%
% (string, string, string) -> (None)
% Runs MuscleAnalysis on a motion and writes the results to a directory

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2026 Rice University and the Authors                      %
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

function runMuscleAnalysis(modelFileName, motionFileName, resultsDirectory)
import org.opensim.modeling.AnalyzeTool
import org.opensim.modeling.MuscleAnalysis
import org.opensim.modeling.Storage
modelFileName = char(GetFullPath(char(modelFileName)));
motionFileName = char(GetFullPath(char(motionFileName)));
resultsDirectory = char(GetFullPath(char(resultsDirectory)));
if ~isfolder(resultsDirectory)
    mkdir(resultsDirectory);
end
[~, name] = fileparts(motionFileName);
motion = Storage(motionFileName);

tool = AnalyzeTool();
tool.setName(name);
tool.setModelFilename(modelFileName);
tool.setCoordinatesFileName(motionFileName);
tool.setLowpassCutoffFrequency(-1);
tool.setInitialTime(motion.getFirstTime());
tool.setFinalTime(motion.getLastTime());
tool.setResultsDir(resultsDirectory);

analysis = MuscleAnalysis();
analysis.setName("MuscleAnalysis");
analysis.setOn(true);
analysis.setStepInterval(1);
analysis.setComputeMoments(true);
analysis.setStartTime(motion.getFirstTime());
analysis.setEndTime(motion.getLastTime());
tool.getAnalysisSet().cloneAndAppend(analysis);

settingsFile = fullfile(resultsDirectory, name + "_MuscleAnalysisSettings.xml");
tool.print(settingsFile);
tool = AnalyzeTool(settingsFile);
if ~tool.run()
    throw(MException('', "OpenSim's MuscleAnalysis did not complete " + ...
        "for " + motionFileName));
end
end
