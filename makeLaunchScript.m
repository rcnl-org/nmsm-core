% This script generates a batch command to launch MATLAB and load the NMSM
% Pipeline in one step. The generated command can be moved anywhere. This 
% currently only works on Windows computers. 

% Get project location
path = mfilename("fullpath");
[path, ~, ~] = fileparts(path);
projectLocation = strrep([path '\Project.prj'], '\', '\\');

% Print batch command file
fileID = fopen('NMSM Pipeline.bat', 'w');
fprintf(fileID, ['matlab.exe -r "open(''' projectLocation ''')"']);
fclose(fileID);
