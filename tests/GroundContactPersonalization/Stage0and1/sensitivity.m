tic
settingsFileName = "GCP_settings.xml";
settingsTree = xml2struct(settingsFileName);
[inputs, params, resultsDirectory] = ...
    parseGroundContactPersonalizationSettingsTree(settingsTree);
inputs = prepareGroundContactPersonalizationInputs(inputs, params);

% inputs

[initialValues, fieldNameOrder, inputs] = makeInitialValues(inputs, params);

gcpSensitivityAnalysis(initialValues, 2, 1500, 3500, fieldNameOrder, inputs, ...
    params, 1)
toc


%% makeInitialValues from 'optimizeByVerticalGroundReactionForce.m'
function [initialValues, fieldNameOrder, inputs] = makeInitialValues( ...
    inputs, params)
initialValues = [];
fieldNameOrder = [];
inputs.bSplineCoefficientsVerticalSubset = ...
    inputs.bSplineCoefficients(:, [1:4, 6]);
if (params.stageOne.springConstants.isEnabled)
    initialValues = [initialValues inputs.springConstants];
    fieldNameOrder = [fieldNameOrder "springConstants"];
end
if (params.stageOne.dampingFactors.isEnabled)
    initialValues = [initialValues inputs.dampingFactors];
    fieldNameOrder = [fieldNameOrder "dampingFactors"];
end
if (params.stageOne.bSplineCoefficients.isEnabled)
    initialValues = [initialValues ...
        reshape(inputs.bSplineCoefficientsVerticalSubset, 1, [])];
    fieldNameOrder = [fieldNameOrder "bSplineCoefficientsVerticalSubset"];
end
end
