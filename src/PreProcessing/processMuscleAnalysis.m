% This function is part of the NMSM Pipeline, see file for full license.
%
% This function takes an OpenSim Model, the file name of the .mot/.sto of
% the IK results, the list of coordinates of interest, and the 'prefix' of
% the trial (i.e. squat, gait, stair-step) and processes the data correctly
% to be used by the MuscleTendonPersonalization.
%
% The muscle length and moments are calculated and placed in a folder
% named 'prefix' in the current working directory.
%
% (Model, string, Array of string, string) -> (None)
% processes MuscleAnalysis in preparation for MuscleTendonPersonalization

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Claire V. Hammond                                            %
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

function processMuscleAnalysis(model, motionFileName, coordinates, prefix)
import org.opensim.modeling.MuscleAnalysis
import org.opensim.modeling.Storage
state = model.initSystem();
muscleAnalysis = MuscleAnalysis(model);
muscleAnalysis.setStatesStore(Storage(motionFileName));
muscleAnalysis.setCoordinates(stringArrayToArrayStr(coordinates));
muscleAnalysis.setComputeMoments(true);
muscleAnalysis.begin(state);
mkdir(prefix);
muscleAnalysis.printResults(prefix, fullfile(pwd, prefix));
removeUnneededFiles(fullfile(pwd, prefix), prefix);
end

function removeUnneededFiles(directory, prefix)
files = dir(directory);
for i=1:length(files)
    if(~files(i).isdir && contains(files(i).name, prefix))
        if(~(contains(files(i).name, "_MomentArm") || ...
                contains(files(i).name, "_Length")))
            delete(fullfile(directory, files(i).name))
        end
    end
end
end