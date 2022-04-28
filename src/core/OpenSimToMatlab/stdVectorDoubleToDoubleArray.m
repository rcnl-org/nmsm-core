% This function is part of the NMSM Pipeline, see file for full license.
%
% This function iterates through the given StdVectorDouble and adds each
% item to a new MATLAB Array of type double and returns the MATLAB
% structure. Allows easier manipulation of MATLAB double than OpenSim
% StdVectorDouble.
%
% (StdVectorDouble) -> (Array of double)
% Rearranges the ArrayDouble into a MATLAB double array

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

function doubleArray = stdVectorDoubleToDoubleArray(stdVectorDouble)
doubleArray = zeros(1, stdVectorDouble.size());
for i=0:stdVectorDouble.size()-1
    doubleArray(i+1) = stdVectorDouble.get(i);
end
end

