function inputs = parseModel(tree, inputs)
fileName = parseElementTextByName(tree, 'input_model_file');
if ~exist(fileName, "file")
    error(sprintf("Cannot find Model File: %s", fileName))
end
inputs.model = Model(fileName);
inputs.modelFileName = fileName;
end
