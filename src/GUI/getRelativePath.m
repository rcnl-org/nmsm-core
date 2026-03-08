function rel = getRelativePath(filePath, basePath)

    if nargin < 2
        basePath = pwd;
    end

    file = java.io.File(filePath).getCanonicalFile();
    base = java.io.File(basePath).getCanonicalFile();

    rel = char(base.toURI().relativize(file.toURI()).getPath());

end