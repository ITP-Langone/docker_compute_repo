classdef CLOUDMR2DACMRSS<CLOUDMR2DACM
    %MROPTArrayCombiningMethodRSSv2(s,n,js)
    
    properties
        
    end
    
    methods
        
        
        function readConf(this,js)
            
            this.Type=js.Type;
            this.FlipAngleMap=js.FlipAngleMap;
            
            try;this.NoiseFileType=js.NoiseFileType;end
            try;this.NBW=js.NBW;;end;
            
        end
        
        
        
        function O=getParams(this)
            
            O.Type=this.Type;
            O.FlipAngleMap=this.FlipAngleMap;
            O.NoiseFileType=this.NoiseFileType;
            O.NBW=this.NBW;
            
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
            
            
            %NORMAL
            im=this.getSOSImage(this.getSignalKSpace);
            
        end
        
        
        
        
        function snr=SNRrecon(this,signalrawdata,img_matrix,noisecov)
            
            
     
            
            snr = zeros(size(signalrawdata,1),size(signalrawdata,2));
            
            
            
            %                 normal
            %from riccardo.lattanzi@nyumc.org SNR Analysis Toolbox Version 4.0
            for irow = 1:size(signalrawdata,1)
                for icol = 1:size(signalrawdata,2)
                    IM = squeeze(img_matrix(irow,icol,:));
                    signalmag = sqrt(2)*abs( IM' * IM );
                    noisepower = abs(IM' * noisecov * IM);
                    snr(irow,icol) = signalmag / sqrt(noisepower);
                end
            end
            
        end
        
        
        
        
        
        
        
        
    end
    
end




