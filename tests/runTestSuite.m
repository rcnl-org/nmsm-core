matlab.project.loadProject("../");
testResults = runtests('tests', 'IncludeSubfolders', true);

testResults.assertSuccess()
