classdef CLOUDMR2DDI<CLOUDMROutput
    %main class of array combining methods, the constructor is ovewritten by
    %the class constructor
    
    properties
        image0
        image1
        
        
    end
    
    
    
    
    methods
        function this = CLOUDMR2DDI(s0,s1)
            this.logIT('instantiate the class DI','ok')
            this.Type='DI'
            if nargin>0
                try
                    this.setImage0(s0);
                    this.logIT('correctly set the first image','ok');
                catch
                    this.logIT('cannot set the first image','ko');
                end
                
            end
            
            if nargin>1
                try
                    this.setImage1(s1);
                    this.logIT('correctly set the second image','ok');
                catch
                    this.logIT('cannot set the second image','ko');
                end
            end
            
        end
        
        function setImage0(this,f)
            
            this.image0=this.DIgetImage(f);
            this.addToExporter('image2D','Image 1',this.image0);
            
            
            
        end
        
        function setImage1(this,f)
            this.image1=this.DIgetImage(f);
            this.addToExporter('image2D','Image 2',this.image1);
        end
        
        
        function calculate(this)
            this.logIT('start calculation','start');
            if (sum(size(this.image0)-size(this.image1))==0)
                this.logIT('images have the same size','ok');
                
                if(numel(size(this.image0))==2)
                    this.logIT('images are both 2D','ok');
                    try
                        this.addToExporter('image2D','Result Difference Image',this.image1-this.image0);
                        this.logIT('subctraction image is calculated','ok');
                    catch
                        this.logIT('subctraction image is not calculate','ko');
                    end
                    try
                        this.addToExporter('image2D','Result Sum image',this.image1+this.image0);
                        this.logIT('sum image is calculated','ok');
                    catch
                        this.logIT('sum image isn''t calculate','ko');
                    end
                else
                    this.logIT('images are not 2D','ko');
                end
            else
                this.logIT('images has not the same size','ko');
            end
            this.logIT('end calculation','end');
            
        end
        
        
        
        
        
        
        
        function O=DIgetImage(this,X)
            try
                try
                    if(exist(X,'file'))
                        [a,b,c]=fileparts(X);
                        
                    else
                        this.logIT('image doesnt exist','ko');
                    end
                catch
                    this.logIT('image doesnt exist','ko');
                end
                
                
                switch(lower(c(2:end)))
                    case {'dcm','ima'}
                        this.logIT('image is Dicom','ok');
                        try
                            O=dicomread(X);
                        catch
                            this.logIT('cannot read image with dicom read','ko');
                            
                        end
                    case{'jpg','jpeg','bmp','png'}
                        this.logIT('image is not Dicom','ok');
                        try
                            
                            O=imread(X);
                        catch
                            this.logIT('cannot read image with imread','ko');
                        end
                        if numel(size(O))==3
                            O=rgb2gray(O);
                        else
                            this.logIT('this is a weird image with more than 3 dimension (RGB)','ko');
                            
                        end
                    case {'nii'}
                        this.logIT('image is Nifti','ok');
                        try
                            O=load_(X);
                        catch
                            this.logIT('cannot read image with dicom read','ko');
                            
                        end
                        
                end
                
                
                
            catch
                this.logIT('something went wrong during the DI read of the file','ko');
                
            end
            
        end
        %     end
        %     methods (Static)
        function scalarSNR=getRoiSNR(this,roi)
            scalarSNR=NaN;
            
            if exist('roi','var')
                if ~isempty(roi)
                    scalarSNR=DI(this.image0,this.image0,roi);
                end
            end
        end
    end
end


function [SNR] = DI(im1,im2,roi,index)

if nargin<4
    r=find(roi);
else
    r=index;
end
vim1=im1(r);
vim2=im2(r);

SNR=mean(vim1+vim2)./(sqrt(2)*std(vim1-vim2));

end

