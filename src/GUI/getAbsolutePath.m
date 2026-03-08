function fullPath = getAbsolutePath(relativePath, basePath)
    if nargin < 2 || isempty(basePath)
        basePath = pwd;
    end

    fullPath = fullfile(basePath, relativePath);
    fullPath = char(java.io.File(fullPath).getCanonicalPath());

end
end