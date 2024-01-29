% This function accepts a model and .mot file and writes a .trc file that
% contains the marker data for the given motion. Noise can be added
% as a parameter.
% Parameters include: 
%   trcFileName - string - output file 
%   dataRate - number - data rate of mot file
%   translationNoise - number - width of gaussian noise for translational
%       coordinates
%   rotationNoise - number - width of gaussian noise for rotational
%       coordinates

% Copyright RNCL *change later*

% (Model, string, string) -> (None)
% Writes a .trc file from a Model and .mot file.
function TrcFromMot(inputModel, motFileName, params)
[model, state] = Model(inputModel);
storage = org.opensim.modeling.Storage(motFileName);
dataRate = dataRateOrError(params);
table = makeTimeSeriesTableVec3(model, dataRate);
applyValuesFromStorage(model, state, storage, table, params);
trcFileAdapter = org.opensim.modeling.TRCFileAdapter();
trcFileAdapter.write(table, trcFileNameOrDefault(params));
end

% (struct) -> (number)
% Returns the dataRate if it's a number, otherwise throws an error
function dataRate = dataRateOrError(params)
if(isfield(params, 'dataRate'))
    if(isnumeric(params.dataRate))
        dataRate = params.dataRate;
    else
        throw(MException('dataRate must be a number'))
    end
else
    throw(MException('dataRate param required'))
end
end

% (struct) -> (string)
% Returns the trcFileName or default value
function fileName = trcFileNameOrDefault(params)
if(isfield(params, 'trcFileName'))
    if(isstring(params.trcFileName) || ischar(params.trcFileName))
        fileName = params.trcFileName;
    else
        warning('params.trcFileName is not a string, using output.trc')
        fileName = 'output.trc';
    end
else
    throw(MException('trcFileName param required'))
end
end