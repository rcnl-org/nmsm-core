function model = parseModel(tree)
model = Model(parseElementTextByName(tree, 'input_model_file'));
end
