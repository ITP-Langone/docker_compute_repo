classdef CLOUDMR2DACMGRAPPA<CLOUDMRAccelerated
    %this is an initial class derived by the code developped at cbi.
    %sensitivity.
    %http://mriquestions.com/senseasset.html
    %last update 2020 Jan
    %---------------------------------------------------------------------
    %kspace is at the fully sampled size and with zeros on the accelerated
    %position
    
    properties
            
    end
    
    methods
        
        
        
        function readConf(this,js)
            
            this.Type=js.Type;
            
            % FA
            this.FlipAngleMap=js.FlipAngleMap;
            %     NOISE
            this.NoiseFileType=js.NoiseFileType;
            this.NBW=js.NBW;
            % colsens
            this.SensitivityCalculationMethod=js.SensitivityCalculationMethod;
            %i don't want to take the matlab image but it's id o the db
            this.SourceCoilSensitivityMapID=js.SourceCoilSensitivityMap;
            this.SaveCoils=js.SaveCoils;
            this.SourceCoilSensitivityMapSmooth=js.SourceCoilSensitivityMapSmooth;
            
            
            this.AccelerationF = js.AccelerationF;
            this.AccelerationP = js.AccelerationP;
            this.Autocalibration = js.Autocalibration;
            if(isfield(js,'GFactorMask'))
                this.GFactorMaskID =js.GFactorMask;
            else
                
            end
            
        end
        
        
        
        function O=getParams(this)
            
            O.Type=this.Type;
            
            O.FlipAngleMap=this.FlipAngleMap;
            
            O.NoiseFileType=this.NoiseFileType;
            O.NBW=this.NBW;
            
            O.SensitivityCalculationMethod=this.SensitivityCalculationMethod;
            O.SaveCoils=this.SaveCoils;
            %i don't want to take the matlab image but it's id o the db
            O.SourceCoilSensitivityMap=this.SourceCoilSensitivityMapID;
            O.SourceCoilSensitivityMapSmooth=this.SourceCoilSensitivityMapSmooth;
            
            
            O.AccelerationF = this.AccelerationF;
            O.AccelerationP = this.AccelerationP;
            
            O.GFactorMask =this.GFactorMaskID;
            
            
        end
        
        
        
        
               function snr=getSNR(this)
                 Kcoils=this.getSignalKSpace();
                 [nrow, ncol,NC]=size(Kcoils);
                   snr=NaN(nrow,ncol);
               end
        
        
        
        
        
        
        function [o]=getImage(this)
            sens=this.getSensitivityMatrix();
            sens=this.bartMy2DKSpace(sens);
            K=this.bartMy2DKSpace(this.getSignalKSpace());
            o = bart('pics -r0.', K, sens);
        end
        
        
        
        
    end
end


