function relativePath = getRelativePath(filePath, basePath)
    if strcmp(filePath, "")
        relativePath = filePath;
        return
    end
    if nargin < 2
        basePath = pwd;
    end
    
    % If the path given is already relative, or is in a different drive, we
    % are not dealing with it.
    basePathParts = strsplit(fileparts(basePath), ["\", "/"]);
    if ~startsWith(fileparts(filePath), basePathParts(1))
        relativePath = filePath;
        return
    end

    file = java.io.File(filePath).getCanonicalFile();
    base = java.io.File(basePath).getCanonicalFile();

    relativePath = char(base.toURI().relativize(file.toURI()).getPath());
end