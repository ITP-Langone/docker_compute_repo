classdef CLOUDMR2DMR<CLOUDMROutput
    %main class of array combining methods, the constructor is ovewritten by
    %the class constructor
    
    properties
        imageArray
        imageSize
        SNR
        MEAN
        STD
    end
    
    
    
    
    
    methods
        function this = CLOUDMR2DMR(x)
            %the class expects a 3D matrix composed by a tile of 2D images
            %or nothing
            this.Type='MR';
            if nargin>0
                for t=1:size(x,3)
                    this.addImage(x());
                end
                
            end
        end
        
        
        function this=add2DImage(this,IM)
            this.imageArray=cat(3,this.imageArray,  IM);
        end
        
        function this=add2DKSPaceFullysampledData(this,KS)
            
            this.imageArray=cat(3,this.imageArray,  CLOUDMROutput.getSOSImage(KS));
        end
        
        
      
        
        
        function calculate(this)
            
                
                this.MEAN=squeeze(mean(this.imageArray,3));
                this.STD=squeeze(std(this.imageArray,0,3));
                this.SNR=this.MEAN./this.STD;
            
            
        end
        
        
        function O=getSNR(this)
            if isempty(this.SNR)
                this.calculate();
            end
            
            O=this.SNR;
        end
        
        
        function O=getMEAN(this)
            if isempty(this.MEAN)
                this.calculate();
            end
            
            O=this.MEAN;
        end
        
        
        function O=getSTD(this)
            if isempty(this.STD)
                this.calculate();
            end
            
            O=this.STD;
        end
        
        
        
        
        
    end
    methods (Static)
        
        
        
        
    end
    
end



