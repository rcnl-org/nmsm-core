% This function is part of the NMSM Pipeline, see file for full license.
%
% () -> ()
% 

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

function inputs = getDiscreteCostTerms(tree, inputs)
trackingDiscreteTermsTree = getFieldByName(tree, 'RCNLTrackingCostTerms');
if isstruct(trackingDiscreteTermsTree)
    if isfield(trackingDiscreteTermsTree.RCNLCostTermSet.objects, 'RCNLCostTerm')
        rcnlCostTermTree = ...
            trackingDiscreteTermsTree.RCNLCostTermSet.objects.RCNLCostTerm;
        if length(rcnlCostTermTree) > 1
            inputs.discrete.tracking = ...
                parseRcnlCostTermSet(rcnlCostTermTree);
        else
            inputs.discrete.tracking = ...
                parseRcnlCostTermSet({rcnlCostTermTree});
        end
    end
end

minimizingDiscreteTermsTree = getFieldByName(tree, 'RCNLMinimizationCostTerms');
if isstruct(minimizingDiscreteTermsTree)
    if isfield(minimizingDiscreteTermsTree.RCNLCostTermSet.objects, 'RCNLCostTerm')
        rcnlCostTermTree = ...
            minimizingDiscreteTermsTree.RCNLCostTermSet.objects.RCNLCostTerm;
        if length(rcnlCostTermTree) > 1
            inputs.discrete.minimizing = ...
                parseRcnlCostTermSet(rcnlCostTermTree);
        else
            inputs.discrete.minimizing = ...
                parseRcnlCostTermSet({rcnlCostTermTree});
        end
    end
end
end