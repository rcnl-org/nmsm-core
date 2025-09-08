% This function is part of the NMSM Pipeline, see file for full license.
%
% 
% (struct, struct) -> (None)
% Compare field names against a reference set, throwing an error if there
% is a mismatch.

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

function checkSpellingInContext(tree, referenceTree, contextString)
validFields = ["", string(fieldnames(referenceTree))'];

fileFields = string(fieldnames(tree))';

% Create and use searcher
searcher = editDistanceSearcher(validFields, 8);
wordIndices = knnsearch(searcher, fileFields);
wordIndices(isnan(wordIndices)) = 1;
correctWords = validFields(wordIndices);
correctionIndices = ~strcmp(fileFields, correctWords);

% Report detected errors
errorString = string(newline);
for i = 1 : length(correctionIndices)
    if correctionIndices(i)
        if wordIndices(i) == 1
            errorString = errorString + "<" + fileFields(i) + "> is " + ...
                "an invalid field name in " + contextString + "." + ...
                newline + newline;
        else
            errorString = errorString + "<" + fileFields(i) + "> is " + ...
                "an invalid field name in " + contextString + ". " + ...
                "Did you mean <" + validFields(wordIndices(i)) + ">?" + ...
                newline + newline;
        end
    end
end
if any(correctionIndices)
    error(errorString)
end
end
