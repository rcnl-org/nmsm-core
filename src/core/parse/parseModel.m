function inputs = parseModel(tree, inputs)
fileName = parseElementTextByName(tree, 'input_model_file');
inputs.model = Model(fileName);
inputs.modelFileName = fileName;
end
