function fullPath = getAbsolutePath(filePath, basePath)
    if nargin < 2 || isempty(basePath)
        basePath = pwd;
    end

    fullPath = fullfile(basePath, filePath);
    % fullPath = char(java.io.File(fullPath).getCanonicalPath());
end