classdef CLOUDMR2DACMB1BART<CLOUDMR2DACMB1
    
    
    properties
        
    end
    
    methods
        
        
     
        
        
        function im=getImage(this)
            S=this.getSensitivityMatrix();
            
            noisecov=this.getNoiseCovariance();
            signalrawdata=this.getSignalKSpace;
            
            
            
            zf_coils = bart('fft -i 3', this.bartMy2DKSpace(this.getSignalKSpace()));
            img_matrix=this.debartMy2DKSpace(zf_coils);
            
            for irow = 1:size(signalrawdata,1)
                for icol = 1:size(signalrawdata,2)
                    s_matrix = squeeze(S(irow,icol,:));
                    im(irow,icol) = abs((s_matrix')*inv(noisecov)*squeeze(img_matrix(irow,icol,:)));
                    
                end
            end
            
            
            
            
        end
        
            
            
        
        
        
        
        
    end
    
    
    
end


