% This function is part of the NMSM Pipeline, see file for full license.
%
% For plotting functions only
% Creates tracked and results structs from given data files

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
function [tracked, results] = parsePlottingData(trackedDataFile, resultsDataFiles, model)
    import org.opensim.modeling.*
    if nargin < 3
        model = org.opensim.modeling.Model();
    end
    tracked = struct();
    results = struct();
    if ~isempty(trackedDataFile)
        tracked.dataFile = trackedDataFile;
        results.dataFiles = resultsDataFiles;
        trackedDataStorage = Storage(trackedDataFile);
        [tracked.labels, tracked.time, tracked.data] = parseMotToComponents(...
            model, trackedDataStorage);
        tracked.data = tracked.data';
        % We want time points to start at zero.
        if tracked.time(1) ~= 0
            tracked.time = tracked.time - tracked.time(1);
        end
        tracked.normalizedTime = tracked.time / tracked.time(end);
    end
    results.data = {};
    results.labels = {};
    results.time = {};
    for j=1:numel(resultsDataFiles)
        resultsDataStorage = Storage(resultsDataFiles(j));
        [results.labels{j}, results.time{j}, results.data{j}] = parseMotToComponents(...
            model, resultsDataStorage);
        results.data{j} = results.data{j}';
        if results.time{j} ~= 0
            results.time{j} = results.time{j} - results.time{j}(1);
        end
        results.normalizedTime{j} = results.time{j} / results.time{j}(end);
    end
end