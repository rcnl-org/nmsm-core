footError = zeros()

% calc foot error implementation

nmm = 2;
toenmm = 3;
fd = HFtol(1,1:9) + nmm;
fd(1,10:12) = Toetol(1,1:3) + toenmm;
error = 1000*footError / (repmat(fd, 101, 1));
