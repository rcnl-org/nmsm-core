% This function is part of the NMSM Pipeline, see file for full license.
%
% This function runs the continuous function to allow users to check that
% the optimization has been setup correctly. Additionally, the user's
% initial guesses are plotted to allow the user to visualize their initial 
% guess. 
% 
% (struct, struct, function handle) -> ()
% Checks to that continuous function works and plots initial guess

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Marleny Vega                                                 %
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

function inputs = checkInitialGuess(guess, inputs, continuousFunction)
initialGuess = guess;
initialGuess.auxdata = inputs;
if isfield(initialGuess,'parameter')
    initialGuess.phase.parameter = initialGuess.parameter;
end
output = continuousFunction(initialGuess);
output.solution = initialGuess;
if length(output.metabolicCost) == length(inputs.experimentalTime)
cumulativeMetabolicCost = trapz(inputs.experimentalTime, ...
    output.metabolicCost);
inputs.initialMetabolicCost = cumulativeMetabolicCost;
inputs.initialMassCenterVelocity = output.massCenterVelocity;
end
end

function value = simpsons(time, data)
h=time(2) - time(1);
value = h/3*(data(1)+2*sum(data(3:2:end-2))+4*sum(data(2:2:end))+data(end));
end