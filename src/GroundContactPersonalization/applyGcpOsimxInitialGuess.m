% This function is part of the NMSM Pipeline, see file for full license.
%
% This function overrides the default Ground Contact Personalization initial
% guess with values parsed from an osimx file. GCP design variables (spring
% constants, damping factor, friction coefficients, and resting spring
% length) are global across all contact surfaces, so the initial guess is
% taken from the osimx contact surface whose hindfoot body matches a surface
% in the current run. If no contact surface in the osimx matches a surface in
% the run, the default initial guesses are kept. Per-spring constants are
% only applied when the osimx surface has the same number of springs as the
% current run.
%
% (struct) -> (struct)
% Returns inputs with osimx-based initial guess overrides applied

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

function inputs = applyGcpOsimxInitialGuess(inputs)
if ~isfield(inputs, "osimx") || ~isfield(inputs.osimx, "groundContact") || ...
        ~isfield(inputs.osimx.groundContact, "contactSurface")
    warning("input_osimx_file contains no RCNLContactSurface elements; " + ...
        "using default initial guesses.");
    return
end
osimxSurfaces = inputs.osimx.groundContact.contactSurface;
matchedSurface = findMatchingOsimxSurface(inputs.surfaces, osimxSurfaces);
if isempty(matchedSurface)
    warning("No contact surface in the osimx file matches a surface in the " + ...
        "run; using default initial guesses.");
    return
end
if isfield(matchedSurface, "restingSpringLength")
    inputs.restingSpringLength = matchedSurface.restingSpringLength;
end
if isfield(matchedSurface, "dampingFactor")
    inputs.dampingFactor = matchedSurface.dampingFactor;
end
if isfield(matchedSurface, "dynamicFrictionCoefficient")
    inputs.dynamicFrictionCoefficient = ...
        matchedSurface.dynamicFrictionCoefficient;
end
if isfield(matchedSurface, "viscousFrictionCoefficient")
    inputs.viscousFrictionCoefficient = ...
        matchedSurface.viscousFrictionCoefficient;
end
if isfield(matchedSurface, "springs")
    osimxSpringConstants = cellfun(@(spring) spring.springConstant, ...
        matchedSurface.springs);
    if length(osimxSpringConstants) == inputs.numSpringMarkers
        inputs.springConstants = osimxSpringConstants;
    else
        warning("The osimx file has %d springs but the current run has %d " + ...
            "spring markers; using the default spring constant.", ...
            length(osimxSpringConstants), inputs.numSpringMarkers);
    end
end
end

% Returns the first osimx contact surface whose hindfoot body matches a
% surface in the run, or an empty array if none match.
function matchedSurface = findMatchingOsimxSurface(runSurfaces, osimxSurfaces)
matchedSurface = [];
for foot = 1 : length(runSurfaces)
    runHindfootBodyName = runSurfaces{foot}.hindfootBodyName;
    for i = 1 : length(osimxSurfaces)
        if strcmp(osimxSurfaces{i}.hindfootBodyName, runHindfootBodyName)
            matchedSurface = osimxSurfaces{i};
            return
        end
    end
end
end
