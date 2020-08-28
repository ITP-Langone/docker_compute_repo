classdef CLOUDMRAccelerated<CLOUDMR2DACMWithSensitivityAutocalibrated
    %this is an initial class derived by the code developped at cbi.
    %sensitivity.
    %http://mriquestions.com/senseasset.html
    %last update 2020 Jan
    %---------------------------------------------------------------------
    %kspace is at the fully sampled size and with zeros on the accelerated
    %position
    
    properties
    Accelerated=true;
                AccelerationF
        AccelerationP
        GFactorMask
        GFactorMaskID
    end
    
    methods
                
    end
end


