clear

lastStage = 2;

for i = 1:8

try
    [inputs, params] = parseGroundContactPersonalizationSettingsTree(...
        xml2struct("GCP_test_" + i + ".xml"));
    inputs = prepareGroundContactPersonalizationInputs(inputs, params);
    inputs = optimizeDeflectionAndSpringContants(inputs, params);
    if lastStage >= 1
        inputs = optimizeByVerticalGroundReactionForce(inputs, params);
    end
    if lastStage >= 2
        inputs = optimizeByGroundReactionForces(inputs, params);
    end
    save("testResultsGcp_" + i + ".mat")
catch
    disp("Failed to run test " + i)
end

end
