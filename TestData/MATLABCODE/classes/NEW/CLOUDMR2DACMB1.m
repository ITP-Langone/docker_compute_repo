classdef CLOUDMR2DACMB1<CLOUDMR2DACMWithSensitivity
    
    
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
            
            
        end
        
        
        
        function O=getParams(this)
            
            O.Type=this.Type;
            
            O.FlipAngleMap=this.FlipAngleMap;
            
            O.NoiseFileType=this.NoiseFileType;
            O.NBW=this.NBW;
            
            O.SensitivityCalculationMethod=this.SensitivityCalculationMethod;
            O.SaveCoils=this.SaveCoils;
            O.SourceCoilSensitivityMap=this.SourceCoilSensitivityMapID;
            O.SourceCoilSensitivityMapSmooth=this.SourceCoilSensitivityMapSmooth;
        end
        
        
        
        
        
        
        function o=getSNR(this)
            %this method works on 2d images only
            noisecov=this.getNoiseCovariance();
            signalrawdata=this.getSignalKSpace;
            img_matrix=this.get2DKSIFFT(this.getSignalKSpace);
            
            this.SNR=this.SNRrecon(signalrawdata,img_matrix,noisecov);
            o=this.SNR;
        end
        
        
        
        
        
        function im=getImage(this)
            S=this.getSensitivityMatrix();
            
            noisecov=this.getNoiseCovariance();
            signalrawdata=this.getSignalKSpace;
            img_matrix=this.get2DKSIFFT(this.getSignalKSpace);
            
            for irow = 1:size(signalrawdata,1)
                for icol = 1:size(signalrawdata,2)
                    s_matrix = squeeze(S(irow,icol,:));
                    im(irow,icol) = abs((s_matrix')*inv(noisecov)*squeeze(img_matrix(irow,icol,:)));
                    
                end
            end
            
            
            
            
        end
        
        
        function snr=SNRrecon(this,signalrawdata,img_matrix,noisecov)
            
            S=this.getSensitivityMatrix();
            
            
            for irow = 1:size(signalrawdata,1)
                for icol = 1:size(signalrawdata,2)
                    s_matrix = squeeze(S(irow,icol,:));
                    snr(irow,icol) = sqrt(2)*abs((s_matrix')*inv(noisecov)*squeeze(img_matrix(irow,icol,:)))/...
                        sqrt((s_matrix')*inv(noisecov)*s_matrix);
                    
                end
            end
            
            
            
        end
        
        
        
        
        
    end
    
    
    
end


