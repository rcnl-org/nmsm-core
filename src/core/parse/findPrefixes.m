% This function is part of the NMSM Pipeline, see file for full license.
%
% This function finds the prefixes of the trials to be used in the
% personalization process. If the trial_prefixes field is present in the
% config file, the prefixes are taken from there. Otherwise, the prefixes
% are taken from the names of the files in the IDData folder.
%
% (struct, string) -> (None)
% finds the prefixes of the trials to be used in the personalization

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Claire V. Hammond, Marleny Vega                              %
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

function prefixes = findPrefixes(tree, inputDirectory)
prefixField = getFieldByName(tree, 'trial_prefixes');
if isstruct(prefixField) && length(prefixField.Text) > 0
    includedPrefixes = strsplit(prefixField.Text, ' ');
else
    includedPrefixes = false;
end
files = dir(fullfile(inputDirectory, "IDData"));
if isempty(files)
    files = dir(fullfile(inputDirectory, "IKData"));
end

prefixes = string([]);
for i=1:length(files)
    if(~files(i).isdir) && (islogical(includedPrefixes) || contains(files(i).name, includedPrefixes))
        prefixes(end+1) = files(i).name(1:end-4);
    end
end
end
