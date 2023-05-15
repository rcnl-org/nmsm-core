% This function is part of the NMSM Pipeline, see file for full license.
%
% Produce a new processed EMG file using RCNL's protocol for turning a
% matrix of double of EMG data into processed EMG data.
%
% (2D Array of double, 1D Array of double, string, struct) -> (None)
% Processes the input EMG data by RCNL's protocol

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

function processRawEmgFile(emgFilename, filterOrder, highPassCutoff, ...
    lowPassCutoff, processedEmgFileName)
emgStorage = org.opensim.modeling.Storage(emgFilename);
timePoints = findTimeColumn(emgStorage);
columnNames = getStorageColumnNames(emgStorage);
rawData = storageToDoubleMatrix(emgStorage);

processedData = processEmg( ...
                            rawData, ...
                            timePoints, ...
                            struct( ...
                                "filterOrder", filterOrder, ...
                                "highPassCutoff", highPassCutoff, ...
                                "lowPassCutoff", lowPassCutoff ...
                                ));

writeToSto(columnNames, timePoints, processedData, processedEmgFileName);
end

