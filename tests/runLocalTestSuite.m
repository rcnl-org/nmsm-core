% This script runs the test suite in the local environment and returns and
% error if any of the scripts do not work as intended. It also includes a
% code coverage report. This script should be used to ensure tests are
% passing before pushing the code to the GitHub repository.

% Copyright RCNL *change later*

import matlab.unittest.TestRunner
import matlab.unittest.plugins.CodeCoveragePlugin

coverage = matlab.unittest.plugins.CodeCoveragePlugin.forFolder( ...
    strcat(pwd, '\src'),'IncludingSubfolders',true);
runner = TestRunner.withTextOutput;
runner.addPlugin(coverage)

[parseResults, suites] = matlab.unittest.internal.runtestsParser( ...
    @testsuite,'tests','IncludeSubfolders',true);

results = run(runner, suites);
testResults.assertSuccess()


