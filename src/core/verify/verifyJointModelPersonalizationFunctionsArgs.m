% This function is part of the NMSM Pipeline, see file for full license.
%
% This function throws an error if the input value is not an argument to
% instantiate a cell array of functions for Joint Model Personalization.
% It essentially tests if a cell array of functions can be made
% in a secure environment and allows for catching the error and handling it
% appropriately.
% 
% This function can be used as a simple line in a function or contained
% within a try-catch to allow for a custom message/response.
%
% (Any) -> (None)
% Throws an exception if the input cannot make a cell array of functions.

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Claire Hammond                                               %
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

function verifyJointModelPersonalizationFunctionsArgs(model, input)
model = Model(model); %don't modify original model, or instantiate filename
for i=1:length(input)
    try model.getJointSet().get(input{i}{1});
    catch;MException('', strcat("joint name doesn't exist for entry ", i));
    end
    try
        logical(input{i}{2});
        logical(input{i}{3});
        paramNum = input{i}{4};
        if(~(paramNum >= 0 && paramNum <=2)); throw(MException()); end
    catch
        throw(MException('', 'invalid function input parameters'))
    end
end
end

