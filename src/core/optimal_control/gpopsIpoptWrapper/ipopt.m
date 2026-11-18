% This function is part of the NMSM Pipeline, see file for full license.
%
% Advanced feature, active only when ipopt.opt exists in the current folder:
% useGpopsIpoptWrapper then puts this folder at the front of the path, so
% the calls GPOPS-II makes to ipopt() land here before the IPOPT mex
% GPOPS-II ships. That IPOPT build (3.12.9)
% formats each message into a 1024-byte buffer and crashes MATLAB
% (0xc0000409) on a longer one. GPOPS-II turns on print_user_options, and
% the table of user-set options it prints passes 1023 characters once
% ipopt.opt adds a fifth option. So this function:
%   1. Runs IPOPT on the same problem and options with no MATLAB console
%      output, stopping at iteration 0. IPOPT writes its own option table,
%      "used" column included, to a temporary file through its file
%      output, which has no length limit, and the table is printed here
%      with fprintf. GPOPS-II calls IPOPT once per mesh, so this is skipped
%      when the options and ipopt.opt match the previous call.
%   2. Runs the solve with print_user_options off, leaving its command
%      window output and IPOPT log file otherwise unchanged.
% ipopt("reset") forgets the previous call; useGpopsIpoptWrapper calls it
% once per gpops2 run.
%
% (double array, struct, struct) -> (double array, struct)
% Solves the GPOPS-II NLP with IPOPT after printing IPOPT's option table

% ----------------------------------------------------------------------- %
% The NMSM Pipeline is a toolkit for model personalization and treatment  %
% optimization of neuromusculoskeletal models through OpenSim. See        %
% nmsm.rice.edu and the NOTICE file for more information. The             %
% NMSM Pipeline is developed at Rice University and supported by the US   %
% National Institutes of Health (R01 EB030520).                           %
%                                                                         %
% Copyright (c) 2021 Rice University and the Authors                      %
% Author(s): Xuanning Liu                                                 %
%                                                                         %
% Licensed under the Apache License, Version 2.0 (the "License");         %
% you may not use this file except in compliance with the License.        %
% You may obtain a copy of the License at                                 %
% http://www.apache.org/licenses/LICENSE-2.0.                             %
%                                                                         %
% Unless required by applicable law or agreed to in writing, software     %
% distributed under the License is distributed on an "AS IS" BASIS,       %
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or         %
% implied. See the License for the specific language governing            %
% permissions and limitations under the License.                          %
% ----------------------------------------------------------------------- %

function [x, info] = ipopt(x0, funcs, options)
persistent ipoptMex previousOptions
if nargin == 1 && isequal(x0, "reset")
    ipoptMex = [];
    previousOptions = [];
    return
end
if isempty(ipoptMex)
    ipoptMex = getGpopsIpoptMex();
end
optionsFileText = readIpoptOptionsFile();
currentOptions = {options.ipopt, optionsFileText};
if isequal(currentOptions, previousOptions)
    fprintf("IPOPT options are unchanged since the previous mesh, " + ...
        "option table not repeated\n");
else
    % The table is for checking only, so a failure here must not stop the
    % solve. Invalid options make the solve fail too, with IPOPT's reason.
    try
        printIpoptOptionTable(ipoptMex, x0, funcs, options, ...
            optionsFileText);
    catch exception
        warning("NMSM:ipoptOptionCheck", "IPOPT option table check " + ...
            "failed, the solve continues without it: %s", ...
            exception.message)
    end
    previousOptions = currentOptions;
end
options.ipopt.print_user_options = 'no';
[x, info] = ipoptMex(x0, funcs, options);
end

% IPOPT reads ipopt.opt from the current folder on every call, after the
% options GPOPS-II passes, so a print_user_options line there would win over
% the one set above
function text = readIpoptOptionsFile()
text = '';
if isfile('ipopt.opt')
    text = fileread('ipopt.opt');
end
if ~isempty(regexp(text, '^\s*print_user_options\s+yes', ...
        'lineanchors', 'ignorecase', 'once'))
    error("ipopt.opt in %s sets print_user_options yes, which " + ...
        "crashes MATLAB once IPOPT's option table passes 1023 " + ...
        "characters. Remove the line, NMSM prints the table itself.", pwd)
end
end

% Without a MATLAB console journal (print_level 0) the table reaches only
% the temporary file. The check reads a copy of ipopt.opt without its own
% print settings, which could otherwise hide or redirect the table. IPOPT
% prints the table before iteration 0 in any run, so "used" means the same
% as it would in the solve. Stopping from iterfunc costs one evaluation at
% the initial guess.
function printIpoptOptionTable(ipoptMex, x0, funcs, options, ...
    optionsFileText)
logFile = [tempname '.txt'];
optionsFileCopy = [tempname '.opt'];
cleanup = onCleanup(@() deleteFiles({logFile, optionsFileCopy}));
printSettingLines = ['^\s*(print_user_options|print_level|' ...
    'file_print_level|output_file|option_file_name)\s[^\n]*\n?'];
fid = fopen(optionsFileCopy, 'w');
fprintf(fid, '%s', regexprep(optionsFileText, printSettingLines, '', ...
    'lineanchors', 'ignorecase'));
fclose(fid);
options.ipopt.option_file_name = optionsFileCopy;
options.ipopt.print_level = 0;
options.ipopt.file_print_level = 5;
options.ipopt.output_file = logFile;
options.ipopt.print_user_options = 'yes';
funcs.iterfunc = @(varargin) false;
[~, ~] = ipoptMex(x0, funcs, options);
optionTable = '';
if isfile(logFile)
    logText = strrep(fileread(logFile), sprintf('\r\n'), newline);
    optionTable = regexp(logText, ['List of user-set options:.*?\n\s*\n' ...
        '.*?(?=\n\s*\n)'], 'match', 'once');
    % drop the lines IPOPT prints right after the table, such as its version
    optionTable = regexprep(optionTable, '(\n[^\n=]*)+$', '');
end
if isempty(optionTable)
    warning("IPOPT did not write its option table, the solve " + ...
        "continues without it")
    return
end
fprintf("\nIPOPT options, from a check run of the same problem " + ...
    "stopped at iteration 0:\n%s\n(option_file_name, print_level, " + ...
    "file_print_level, output_file and print_user_options belong to " + ...
    "the check run)\n\n", optionTable);
end

function deleteFiles(paths)
for i = 1 : numel(paths)
    if isfile(paths{i})
        delete(paths{i})
    end
end
end
