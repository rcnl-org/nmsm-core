% This function is part of the NMSM Pipeline, see file for full license.
%
% This function organizes trials based on tasks   %
%
% data:
%   Tasks - cell arrays containing the task names
%   nTrials - number of trials in total - double
%   nTasks -  number of tasks - double
%   TrialNames - trial names for each trial
%
% returns trial index for each task
% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Di Ao, Marleny Vega                                          %
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

function  params = getTrialIndexes(params, nTrials, TrialNames)
%---Identify the trial index according to the labels in 'Tasks'
params.taskNames = unique(params.taskNames);
trialIndex = cell(1, length(params.taskNames));
for i=1:nTrials
    for j=1:length(params.taskNames)
        if contains(TrialNames{i}, params.taskNames{j})
            if isempty(trialIndex{j})
                trialIndex{j} = i;
            else
                trialIndex{j} = [trialIndex{j} i];
            end
        end
    end
end
params.trialIndex = trialIndex;
params.synergyCategorizationOfTrials = getCategorizationOfTrials(...
    params.synergyExtrapolationCategorization, trialIndex, nTrials);
params.residualCategorizationOfTrials = getCategorizationOfTrials(...
    params.residualCategorization, trialIndex, nTrials);
end

function categorizationOfTrials = getCategorizationOfTrials(...
    categorizationMethod, trialIndex, nTrials)
if strcmpi(categorizationMethod, 'trial')
    for i = 1 : nTrials
        categorizationOfTrials{i} = i;
    end
elseif strcmpi(categorizationMethod, 'task')
    categorizationOfTrials = trialIndex;
elseif strcmpi(categorizationMethod, 'subject')
    categorizationOfTrials = {1 : nTrials};
end
end