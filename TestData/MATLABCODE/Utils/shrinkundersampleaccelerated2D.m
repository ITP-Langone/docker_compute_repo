function [KOUT]=shrinkundersampleaccelerated2D(K,frequencyacceleration,phaseacceleration)
%K is a kspace 2d data (frequency,phase,coil)
% phaseacceleration
% set ACS lines for mSense simulation (fully sampled central k-space
% region)




[nX, nY, nCoils]=size(K);



if (~exist('frequencyacceleration','var'))
    frequencyacceleration=1;
end
if (~exist('phaseacceleration','var'))
    phaseacceleration=1;
end



% if autocalibration>=nY
%     KOUT=NaN;
%     return;
% end
%
%
% if mod(autocalibration,2)>0
%     KOUT=NaN;
%     return;
% end

% ACShw = autocalibration/2 ;

Ysamp_u = [1:phaseacceleration:nY] ; % undersampling
nYsamp = length(Ysamp_u) ; % number of actually sampled

Xsamp_u = [1:frequencyacceleration:nX] ; % undersampling
nXsamp = length(Xsamp_u) ; % number of actually sampled

KOUT=K(Xsamp_u,Ysamp_u,:);


    
    
    
    
    
    
    

    
