% This function is part of the NMSM Pipeline, see file for full license.
%
% Per-synergy-row ratio so a weight row exactly hits the given row-sum
% (method='sum') or row-magnitude (method='magnitude') target. Returns
% all-ones if value is NaN - no target requested, weights are left at
% whatever scale they already have. Shared by normalizeFixedSynergyWeights
% (parseNeuralControlPersonalizationSettingsTree.m, optimize_synergy_vectors
% false) and the initial_guess_directory warm-start path
% (prepareNcpInitialValues.m, optimize_synergy_vectors true), so both loaded-
% weight cases use identical ratio math instead of near-duplicate copies.
%
% (2D Array of number, string, number) -> (Array of number)
% Computes per-synergy-row normalization ratios

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Xuanning Liu                                                 %
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

function ratios = computeNcpNormalizationRatios(weights, method, value)
if isempty(value) || isnan(value)
    ratios = ones(size(weights, 1), 1);
    fprintf(['[NCP] No synergy_vector_normalization_value given; loaded ' ...
        'weights are left at their existing scale.\n']);
    return
end
switch lower(method)
    case 'sum'
        ratios = value ./ sum(weights, 2);
    case 'magnitude'
        ratios = value ./ vecnorm(weights, 2, 2);
    otherwise
        error('[NCP] Unknown synergy_vector_normalization_method: "%s"', method);
end
end
