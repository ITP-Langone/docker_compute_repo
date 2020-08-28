classdef CLOUDMR2DACMRSSBART<CLOUDMR2DACMRSS
    
    properties
       
    end
    
    methods
        
        
        
        function im=getImage(this)
            zf_coils = bart('fft -i 3', this.bartMy2DKSpace(this.getSignalKSpace()));
            zf_rss = bart('rss 8', zf_coils);
            im=this.debartMy2DKSpace(zf_rss);
        end
        
    
    
    end
end


