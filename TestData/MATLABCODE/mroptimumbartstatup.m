%this file is needed by Utils/espirit_sensitivitymap
IAMHERE=pwd;
P=fileparts(which ('mroptimumbartstatup'));
cd(fullfile(P,'bart'))
startup

cd(IAMHERE);
clear IAMHERE P;
