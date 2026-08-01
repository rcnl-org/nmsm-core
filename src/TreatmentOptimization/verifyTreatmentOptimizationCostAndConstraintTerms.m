function verifyTreatmentOptimizationCostAndConstraintTerms(inputs)
    verifyCostTerms(inputs.costTerms, inputs)
    verifyConstraintTerms(inputs.path, inputs)
    verifyConstraintTerms(inputs.terminal, inputs)
end

function verifyCostTerms(costTerms, inputs)
    components = searchCostOrConstraintComponents(costTerms);
    warnings = verifyCoordinates(components.coordinates, inputs, ...
        string([]), "cost");
    warnings = verifyLoads(components.loads, inputs, warnings, "cost");
    warnings = verifyMuscles(components.muscles, inputs, warnings, "cost");
    warnings = verifyForces(components.forces, inputs, warnings, "cost");
    warnings = verifyMoments(components.moments, inputs, warnings, "cost");
    for i = 1 : numel(warnings)
        warning(warnings(i))
    end
end

function verifyConstraintTerms(constraintTerms, inputs)
    components = searchCostOrConstraintComponents(constraintTerms);
    warnings = verifyCoordinates(components.coordinates, inputs, ...
        string([]), "constraint");
    warnings = verifyLoads(components.loads, inputs, warnings, "constraint");
    warnings = verifyMuscles(components.muscles, inputs, warnings, "constraint");
    warnings = verifyForces(components.forces, inputs, warnings, "constraint");
    warnings = verifyMoments(components.moments, inputs, warnings, "constraint");
    for i = 1 : numel(warnings)
        warning(warnings(i))
    end
end

function components = searchCostOrConstraintComponents(terms)
components.coordinates = string([]);
components.loads = string([]);
components.muscles = string([]);
components.forces = string([]);
components.moments = string([]);
components.controllers = string([]);
components.markers = string([]);
components.bodies = string([]);

for i = 1 : numel(terms)
    term = terms{i};
    if isfield(term, "coordinate")
        components.coordinates(end+1) = term.coordinate;
    elseif isfield(term, "load")
        components.loads(end+1) = term.load;
    elseif isfield(term, "muscle")
        components.muscles(end+1) = term.muscle;
    elseif isfield(term, "force")
        components.forces(end+1) = term.force;
    elseif isfield(term, "moment")
        components.moments(end+1) = term.moment;
    elseif isfield(term, "controller")
        components.controllers(end+1) = term.controller;
    elseif isfield(term, "marker")
        components.markers(end+1) = term.marker;
    elseif isfield(term, "body")
        components.bodies(end+1) = term.body;
    end
end
components.coordinates = unique(components.coordinates);
components.loads = unique(components.loads);
components.muscles = unique(components.muscles);
components.forces = unique(components.forces);
components.moments = unique(components.moments);
components.controllers = unique(components.controllers);
components.markers = unique(components.markers);
components.bodies = unique(components.bodies);
end

function warnings = verifyCoordinates(coordinates, inputs, warnings, type)
coordinateIndices = ismember(coordinates, ...
    inputs.statesCoordinateNames);
if any(~coordinateIndices)
    warnings = [warnings, strcat("Coordinate ", coordinates( ...
        ~coordinateIndices), " is included in a ", type, " term but is ", ...
        "not in the states coordinate list")];
end
end

function warnings = verifyLoads(loads, inputs, warnings, type)
loadIndices = ismember(loads, ...
    inputs.initialInverseDynamicsMomentLabels);
if any(~loadIndices)
    warnings = [warnings, strcat("Load ", loads( ...
        ~loadIndices), " is included in a ", type, " term but is ", ...
        "not in the inverse dynamics loads file")];
end
end

function warnings = verifyMuscles(muscles, inputs, warnings, type)
try
    muscleIndices = ismember(muscles, ...
        inputs.muscleNames);
    if any(~muscleIndices)
        warnings = [warnings, strcat("Muscle ", muscles( ...
            ~muscleIndices), " is included in a ", type, " term but is ", ...
            "not in the muscle activations file")];
    end
catch
end
end

function warnings = verifyForces(forces, inputs, warnings, type)
try
    forceColumnsCompare = [];
    for k = 1 : numel(inputs.contactSurfaces)
        forceColumnsCompare = [forceColumnsCompare, ...
            inputs.contactSurfaces{k}.forceColumns];
    end
    forceIndices = ismember(forces, forceColumnsCompare);
    if any(~forceIndices)
        warnings = [warnings, strcat("Force ", forces( ...
            ~forceIndices), " is included in a ", type, " term but is ", ...
            "not in the ground reaction file")];
    end
catch
end
end

function warnings = verifyMoments(moments, inputs, warnings, type)
try
    momentColumnsCompare = [];
    for k = 1 : numel(inputs.contactSurfaces)
        momentColumnsCompare = [momentColumnsCompare, ...
            inputs.contactSurfaces{k}.momentColumns];
    end
    momentIndices = ismember(moments, momentColumnsCompare);
    if any(~momentIndices)
        warnings = [warnings, strcat("Moment ", moments( ...
            ~momentIndices), " is included in a ", type, " term but is ", ...
            "not in the ground reaction file")];
    end
catch
end
end

