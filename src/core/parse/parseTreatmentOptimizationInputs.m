% This function is part of the NMSM Pipeline, see file for full license.
%
% This function parses the settings tree resulting from xml2struct from the
% settings XML file common to all treatment optimizatin modules (trackning,
% verification, and design optimization).
%
% (struct) -> (struct, struct)
% returns the input values for all treatment optimization modules

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Marleny Vega, Claire V. Hammond                              %
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

function inputs = parseTreatmentOptimizationInputs(tree)
inputs = parseBasicInputs(tree);
inputs.osimx = parseOsimxFileWithCondition(tree, inputs);
inputs = parseController(tree, inputs);
inputs = parseTreatmentOptimizationDataDirectory(tree, inputs);
inputs = parseOptimalControlSolverSettings(tree, inputs);
inputs.costTerms = parseRcnlCostTermSetHelper( ...
    getFieldByNameOrError(tree, 'RCNLCostTermSet'));
inputs.costTerms = splitListTerms(inputs.costTerms);
inputs.costTerms = splitAxesTerms(inputs.costTerms);
if isequal(mexext, 'mexw64') 
    inputs.calculateAngularMomentum = any(all([ ...
        strcmp(cellfun(@(term) term.type, inputs.costTerms, ...
        'UniformOutput', false), {'angular_momentum_minimization'}) ...
        ; ...
        cell2mat(cellfun(@(term) term.isEnabled, inputs.costTerms, ...
        'UniformOutput', false)) ...
        ], 1));
    inputs.calculateMetabolicCost = any(all([ ...
        strcmp(cellfun(@(term) term.type, inputs.costTerms, ...
        'UniformOutput', false), {'relative_metabolic_cost_per_time'}), ...
        strcmp(cellfun(@(term) term.type, inputs.costTerms, ...
        'UniformOutput', false), {'relative_metabolic_cost_per_distance'}) ...
        ; ...
        cell2mat(cellfun(@(term) term.isEnabled, inputs.costTerms, ...
        'UniformOutput', false)), ...
        cell2mat(cellfun(@(term) term.isEnabled, inputs.costTerms, ...
        'UniformOutput', false)) ...
        ], 1));
    inputs.calculateBrakingImpulse = any(all([ ...
        strcmp(cellfun(@(term) term.type, inputs.costTerms, ...
        'UniformOutput', false), {'braking_impulse_goal'}) ...
        ; ...
        cell2mat(cellfun(@(term) term.isEnabled, inputs.costTerms, ...
        'UniformOutput', false)) ...
        ], 1));
    inputs.calculatePropulsiveImpulse = any(all([ ...
        strcmp(cellfun(@(term) term.type, inputs.costTerms, ...
        'UniformOutput', false), {'propulsive_impulse_goal'}) ...
        ; ...
        cell2mat(cellfun(@(term) term.isEnabled, inputs.costTerms, ...
        'UniformOutput', false)) ...
        ], 1));
end
[inputs.path, inputs.terminal] = parseRcnlConstraintTermSetHelper( ...
    getFieldByNameOrError(tree, 'RCNLConstraintTermSet'), ...
    inputs.controllerType, inputs.toolName);
inputs.path = splitListTerms(inputs.path);
inputs.path = splitAxesTerms(inputs.path);
inputs.path = convertValueToError(inputs.path);
inputs.terminal = splitListTerms(inputs.terminal);
inputs.terminal = splitAxesTerms(inputs.terminal);
inputs.terminal = convertValueToError(inputs.terminal);
end

function inputs = parseBasicInputs(tree)
inputs.toolName = findToolName(tree);
inputs.resultsDirectory = getTextFromField(getFieldByName(tree, ...
    'results_directory'));
if(isempty(inputs.resultsDirectory)); inputs.resultsDirectory = pwd; end
inputs.controllerType = parseControllerType(tree);
inputs = parseModel(tree, inputs);
[~, state] = Model(inputs.model);
inputs.mass = inputs.model.getTotalMass(state);
inputs.normalizeCostByType = getBooleanLogicFromField( ...
    getFieldByNameOrAlternate(tree, 'normalize_cost_by_term_type', false));
end

function osimx = parseOsimxFileWithCondition(tree, inputs)
osimxFileName = parseTextOrAlternate(tree, "input_osimx_file", "");
if ~exist(osimxFileName, "file")
    error(sprintf("Cannot find Input Osimx File: %s", ...
        osimxFileName))
end
osimx = parseOsimxFile(osimxFileName, inputs.model);
if strcmp(inputs.controllerType, "synergy")
    if strcmp(osimxFileName, "")
        throw(MException("", ...
            strcat("<input_osimx_file> must be specified", ...
            " for <RCNLSynergyController>")))
    end
    if ~isfield(osimx, "synergyGroups")
        throw(MException("", ...
            strcat("<RCNLSynergySet> must be specified in the", ...
            " osimx file for <RCNLSynergyController>. Have you run NCP yet?")))
    end
end
end

function costTerms = parseRcnlCostTermSetHelper(tree)
if isfield(tree, "RCNLCostTerm")
    costTerms = parseRcnlCostTermSet(tree.RCNLCostTerm);
else
    costTerms = parseRcnlCostTermSet({});
end
end

function [path, terminal] = parseRcnlConstraintTermSetHelper(tree, ...
    controllerType, toolName)
if isfield(tree, "RCNLConstraintTerm")
    [path, terminal] = parseRcnlConstraintTermSet( ...
        tree.RCNLConstraintTerm, toolName, controllerType);
else
    [path, terminal] = parseRcnlConstraintTermSet({}, controllerType, ...
        toolName);
end
end

function splitTerms = splitListTerms(originalTerms)
splitTerms = {};
listTypes = ["coordinate_list", "load_list", "muscle_list", ...
    "force_list", "moment_list", "marker_list", "controller_list", ...
    "synergy_group_list", "body_list", "hindfoot_body_list", ...
    "synergy_list"];
unlistTypes = ["coordinate", "load", "muscle", ...
    "force", "moment", "marker", "controller", "synergy_group", ...
    "body", "hindfoot_body", "synergy"];
for i = 1 : length(originalTerms)
    termElements = fieldnames(originalTerms{i});
    hasBeenSplit = false;
    for element = 1:length(termElements)
        typeIndex = find(termElements{element} == listTypes, 1);
        if ~isempty(typeIndex)
            newTermTemplate = originalTerms{i};
            newTermTemplate = rmfield(newTermTemplate, termElements{element});
            elementsList = convertCharsToStrings(split(originalTerms{i} ...
                .(termElements{element})));
            for j = 1 : length(elementsList)
                newTerm = newTermTemplate;
                newTerm.(unlistTypes(typeIndex)) = ...
                    convertStringsToChars(elementsList(j));
                splitTerms{end + 1} = newTerm;
            end
            hasBeenSplit = true;
        end
    end
    if ~hasBeenSplit
        splitTerms{end + 1} = originalTerms{i};
    end
end
end

function splitTerms = splitAxesTerms(originalTerms)
splitTerms = {};
for i = 1 : length(originalTerms)
    if isfield(originalTerms{i}, 'axes')
        axes = lower(originalTerms{i}.axes);
        addedTerm = false;
        if any(contains(axes, 'x'))
            tempTerm = originalTerms{i};
            tempTerm.axes = 'x';
            splitTerms{end+1} = tempTerm;
            addedTerm = true;
        end
        if any(contains(axes, 'y'))
            tempTerm = originalTerms{i};
            tempTerm.axes = 'y';
            splitTerms{end+1} = tempTerm;
            addedTerm = true;
        end
        if any(contains(axes, 'z'))
            tempTerm = originalTerms{i};
            tempTerm.axes = 'z';
            splitTerms{end+1} = tempTerm;
            addedTerm = true;
        end
        assert(addedTerm, "Axes should " + ...
            "be defined as some or all of x, y, and z.")
    else
        splitTerms{end+1} = originalTerms{i};
    end
end
end

function terms = convertValueToError(terms)
for i = 1 : length(terms)
    if isfield(terms{i}, 'max_value')
        terms{i}.maxError = terms{i}.max_value;
        terms{i} = rmfield(terms{i}, 'max_value');
    end
    if isfield(terms{i}, 'min_value')
        terms{i}.minError = terms{i}.min_value;
        terms{i} = rmfield(terms{i}, 'min_value');
    end
end
end
