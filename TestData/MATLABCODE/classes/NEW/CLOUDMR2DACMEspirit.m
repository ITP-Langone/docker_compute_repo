classdef CLOUDMR2DACMEspirit<CLOUDMR2DACMmSENSE
    %this is an initial class derived by the code developped at cbi.
    %sensitivity.
    %http://mriquestions.com/senseasset.html
    %last update 2020 Jan
    %---------------------------------------------------------------------
    %kspace is at the fully sampled size and with zeros on the accelerated
    %position
    %the class is just an alias for the msense with the differencies that
    %the sensitivitty maps must be calculated with espirit
    
    properties
        
    end
    
    methods
        
        
     
               function snr=getSNR(this)
                 Kcoils=this.getSignalKSpace();
                 [nrow, ncol,NC]=size(Kcoils);
                   snr=NaN(nrow,ncol);
               end
       


        
    end
end


