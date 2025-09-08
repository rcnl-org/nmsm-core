% This function is part of the NMSM Pipeline, see file for full license.
%
% 
% (struct, struct) -> (None)
% If supported, validate XML field names against reference file.

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Spencer Williams                                             %
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

function checkTreatmentOptimizationSpelling(tree, inputs)
% Only use spell checking if dependencies are installed
if ~license('test', 'Text_Analytics_Toolbox') || ~inputs.checkFieldSpelling
    return
end

% Locate reference file
path = mfilename("fullpath");
[pathParts, splits] = strsplit(path, {'\', '/'});
indices = find(cellfun(@(x) strcmp(x, 'nmsm-core'), pathParts));
index = indices(end);
xmlPath = cell(1, 2 * index - 1);
for i = 1 : index
    xmlPath{2 * i - 1} = pathParts{i};
    if 2 * i < length(xmlPath)
        xmlPath{2 * i} = splits{i};
    end
end
xmlPath = strjoin(xmlPath, '');
xmlPath = fullfile(xmlPath, 'documentation', 'XMLReference', 'TreatmentOptimizationReference.xml');
% Load reference file
referenceTree = xml2struct(xmlPath);
referenceTree = referenceTree.NMSMPipelineDocument.DesignOptimizationTool;

tree = tree.NMSMPipelineDocument.(inputs.toolName + "Tool");

checkSpellingInContext(tree, referenceTree, ...
    "<" + inputs.toolName + "Tool>");

blocksToCheck = ["RCNLCostTermSet", "RCNLConstraintTermSet", ...
    "RCNLMuscleModel", "RCNLTorqueController", ...
    "RCNLSynergyController", "RCNLMuscleController", ...
    "RCNLUserDefinedController"];

for block = blocksToCheck
    if isfield(tree, block)
        checkSpellingInContext(tree.(block), referenceTree.(block), ...
            "<" + block + ">");
    end
end
end
