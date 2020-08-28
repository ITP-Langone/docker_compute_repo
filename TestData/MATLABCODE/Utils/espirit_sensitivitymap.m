function[maps]=espirit_sensitivitymap(DATA, calibrationlines,kernelsize,eigtresh1,eigtresh2)
%compute sepirit sensitivity maps on a 2D image frequency, phase, coils.
%
%input: Kspace,numebr fo calibration lines [24], kernale size [6 6],
%treshold eigen 1 [0.2], treshold eigen 2 [0.95]


%mroptimumbartstatup();
[sx,sy,Nc] = size(DATA);
ncalib = 24; % use 24 calibration lines to compute compression
ksize = [6,6]; % kernel size

% Threshold for picking singular vercors of the calibration matrix
% (relative to largest singlular value.

eigThresh_1 = 0.02;

% threshold of eigen vector decomposition in image space.
eigThresh_2 = 0.95;



if exist('calibrationlines','var')
    if ~isempty(calibrationlines)
        ncalib=calibrationlines;
    end
end



if exist('kernelsize','var')
    if ~isempty(kernelsize)
        ksize=kernelsize;
    end
end




if exist('eigtresh1','var')
    if ~isempty(eigtresh1)
        eigThresh_1=eigtresh1;
    end
end


if exist('eigtresh2','var')
    if ~isempty(kernelsize)
        eigThresh_2=eigtresh2;
    end
end



% crop a calibration area
calib = crop(DATA,[ncalib,ncalib,Nc]);



% compute Calibration matrix, perform 1st SVD and convert singular vectors
% into k-space kernels

[k,S] = dat2Kernel(calib,ksize);
idx = max(find(S >= S(1)*eigThresh_1));


% W Eigen Values in Image space, M Magnitude of Eigen Vectors')
[M,W] = kernelEig(k(:,:,:,1:idx),[sx,sy]);


maps = M(:,:,:,end).*repmat(W(:,:,end)>eigThresh_2,[1,1,Nc]);
