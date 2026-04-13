function rel = getRelativePath(filePath, basePath)
    if strcmp(filePath, "")
        rel = filePath;
        return
    end
    if nargin < 2
        basePath = pwd;
    end

    % Check if path is absolute
    filepath = fileparts(filePath);

    pwdParts = strsplit(fileparts(pwd), ["\", "/"]);

    if startsWith(filepath, pwdParts{1})
        filePath = fullfile(pwd, filePath);
    end


    % if ~exist(filePath, "file")
    %     rel = filePath;
    %     return
    % end

    file = java.io.File(filePath).getCanonicalFile();
    base = java.io.File(basePath).getCanonicalFile();

    rel = char(base.toURI().relativize(file.toURI()).getPath());
end