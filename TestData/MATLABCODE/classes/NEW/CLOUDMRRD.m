classdef CLOUDMRRD<CLOUDMROutput
    %CLAOUDMRRDa this is the basic data structure for the SNR calculation
    %   v2 October 23, NYULMC
    %   Eros Montin eros.montin@gmail.com
    %
    %properties(Access=private) 7D kspace
    
    properties
        FileName
        Reader
        ImageKS
        NoiseKS
        RefscanKS
    end
    
    methods
        function this = CLOUDMRRD(f)
            if nargin>0
                this.setFilename(f);
            end
        end
        function o=getFilename(this)
            o=this.FileName;
        end
        function setFilename(this,f)
            this.FileName=f;
        end
        
        function readFile(this)
            [pt,n,e]=fileparts(this.getFilename);
            switch lower(e)
                case '.h5'
                    this.Reader=CLOUDMRIsmrmRawDataReader(this.getFilename());
                case '.dat'
                    this.Reader=CLOUDMRSiemensRawDataReader(this.getFilename());
            end
            
        end
        
        function setImageKSpace(this,f)
            this.ImageKS=f;
        end
        
        function setNoiseKSpace(this,f)
            this.NoiseKS=f;
        end
        
        function o=getImageKSpace(this)
            
            

            
            if isempty(this.ImageKS)
                            if (isempty(this.Reader))
                                this.readFile();
                            end            
                this.ImageKS=this.Reader.readImageKSpace();
            end
            
            
            o=this.ImageKS;
            
            
            
            
        end
        
        
        
        function o=setCLOUDMRRDImageKSpacefrom2Dslice(this,K,av,c,r,s)
            %it must be 4D freq,phase slice and coils
            [NF NP NC]=size(K);
                
            
            
            NK=zeros(1,1,1,NF,NP,1,NC);
            NK(1,1,1,:,:,1,:)=K;
            if isempty(this.ImageKS)
                this.setImageKSpace(NK);
            else                
                OK=this.ImageKS;
                OK(av,c,r,:,:,s,:)=NK;
            end
            
            this.setImageKSpace(NK);
        end
        
        
        function o=getNoiseKSpace(this)
            
            
           
            
            if isempty(this.NoiseKS)
                 if (isempty(this.Reader))
                this.readFile();
                end
                this.NoiseKS=this.Reader.readNoiseKSpace();
            end
            
            
            
            o=this.NoiseKS;
            
            
            
        end
        
        
        function O=getKSpaceDimensionsName(this)
            %display('1: Average','2: contrast','3: repetition,4: Frequency Encode','5: Phase Encode','6: Slice','7: Coils,');
            O={'1: Average','2: contrast','3: repetition','4: Frequency Encode','5: Phase Encode','6: Slice','7: Coils'};
        end
        
        function o=getKSpaceNoiseSlice(this,a,c,r,s)
            
            if (strcmp(a,'avg') || (a==0))
               X=this.averageKS(this.getNoiseKSpace());
               a=0;
            else
                X=this.getNoiseKSpace();
            end
            
            o=this.reduceKSpace2DSlice(X,a,c,r,s);
        end
        
        
        
        
        
        
        function o=getKSpaceImageSlice(this,a,c,r,s)
            %this function get me the slice of the signal
            %average,contrast,repetition,slice)
            if (strcmp(a,'avg') || (a==0))
               X=this.averageKS( this.getImageKSpace());
               a=0;
            else
                X= this.getImageKSpace();
            end
            
           
            
            
            
            o=this.reduceKSpace2DSlice(X,a,c,r,s);
        end
        
        function o=getNumberImageSlices(this)
            
            o=this.getNSlices(this.getImageKSpace());
        end
        
        
                function o=getNumberNoiseSlices(this)
            
            o=this.getNSlices(this.getNoiseKSpace());
        end
        
        
        function o=getNumberRepetition(this)
            
            o=this.getNRepetition(this.getImageKSpace());
        end
        
        
    end
    
    methods (Static)
        
        
        function O=getNSlices(K)
            O= size(K,6);
        end
        
        
        function O=averageKS(K)
            O= mean(K,1);
        end
        
        function O=getNRepetition(K)
            O= size(K,3);
        end
        
        
        function O=getNAverages(K)
            O= size(K,1);
        end
        

                function O=getNContrast(K)
            O= size(K,2);
                end

        
                
        function O= reduceKSpace2DSlice(K,a,c,r,s)
            %average,contrast,repetition,slice
            %if average =0 (we make average) else
            %we provide that particular average image the output is 3D (freq,fase,coils)
            
            S=CLOUDMRRD.getKspace3Dsize(K);
            C=CLOUDMRRD.getNCoil(K);
            %the average can be 1 if the kspace is averaged
            if (a==0)
                K=CLOUDMRRD.averageKS(K);
                O=reshape(K(1,c,r,:,:,s,:),[S(1) S(2) C]);
            else
                O=reshape(K(a,c,r,:,:,s,:),[S(1) S(2) C]);
            end
            
        end
        
        
        
        function O=getKspace3Dsize(K)
            
            O= [size(K,4) size(K,5) size(K,6)];
        end
        
        
        function O=getNCoil(K)
            
            O= size(K,7);
        end
        
        
    end
    
end

