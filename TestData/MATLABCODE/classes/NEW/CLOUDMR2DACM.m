classdef CLOUDMR2DACM<CLOUDMROutput
    %main class of array combining methods, the constructor is ovewritten by
    %the class constructor
    
    properties
        SignalKSpace
        NoiseKSpace
        NBW %noise bandith correction on the kellman filter
        SignalNCoils
        NoiseNCoils
        SNR
        state
        noisebandwidth
        Map
        FlipAngleMap
        NoiseFileType
            end
    
    
    
    
    
    methods
        function this = CLOUDMR2DACM(s,n,js)
            %the class expects a 3D matrix composed by a tile of 2D kspaces (fxpxncoils) of a signal and a
            %noise.
            %sjs is a structure with the needed properties of the
            %calss
            this.Type='ACM';
            this.logIT(['class ' class(this) ' instantiated'],'ok');
            
            if nargin>0
                this.setSignalKSpace(s);
            end
            
            if nargin>1
                this.setNoiseKSpace(n);
            end
            
            %read and set options
            if exist('js','var')
                this.readConf(js);
            end
        end
        
        
        %         function readConf(this,js)
        %             L=fieldnames(js);
        %             for t=1:numel(L)
        %                 eval(['this.' L{t} ' = js.' L{t} ';']);
        %             end
        %         end
        
        
        function setConf(this,js)
            this.readConf(js);
        end
        
        
                
        function o=needsSensitivity(this)
            o= isprop(this,'WithSensitivity');
                
        end
            
        
            function o=isAccelerated(this)
            o= (isprop(this,'Accelerated') || strcmpi(this.Type,'sense'));
                
            end
        
        
        function O=faCorrection(this)
            
            
            if strcmp(this.FlipAngleMap,'no')
                O=false;
            else
                O=true;
            end
            
        end
        
        function setNoiseKSpace(this,f)
            % 2DKspace
            this.NoiseKSpace=f;
            this.setNoiseNCoils(size(f,3));
        end
        
        function o =getNoiseKSpace(this)
            % 2DKspace
            o = this.NoiseKSpace;
        end
        
        
        function setSignalKSpace(this,f)
            %2Dkspace
            this.SignalKSpace=f;
            this.setSignalNCoils(size(f,3));
        end
        
        function o=getSignalKSpace(this)
            o=this.SignalKSpace;
        end
        
        function resetSNR(this)
            this.SNR=[];
            this.logIT('reset the SNR','ok');
            
        end
        
        
        
        
        function setSignalNCoils(this,n)
            this.SignalNCoils=n;
        end
        
        
        function setNoiseNCoils(this,n)
            this.NoiseNCoils=n;
        end
        
        function o= getSignalNCoils(this)
            o=this.SignalNCoils;
        end
        
        
        function o =getFlipAngleMap(this)
            % 2DKspace
            o = this.FlipAngleMap;
        end
        
        
        
        function o=getNoiseNCoils(this)
            o=this.NoiseNCoils;
        end
        
        function o=getNoiseBanwidth(this)
            if(isempty( this.noisebandwidth))
                noise_bandwidth = mrir_noise_bandwidth(this.getNoiseKSpace,0);
                
                this.noisebandwidth=noise_bandwidth;
            end
            
            o=this.noisebandwidth;
            
        end
        
        
        
        
        function o=getNoiseCovariance(this)
            %from calc_noise_cov(noise,bw_correction);       %%2D
            noise=this.NoiseKSpace;
            
            nchan = this.getNoiseNCoils();
            % Siemens method
            noisecovbis = zeros(nchan);
            for iCh = 1:nchan
                for jCh = 1:nchan
                    noisecovbis(iCh,jCh)=sum(sum(noise(:,:,iCh).*conj(noise(:,:,jCh))))/(size(noise,1)*size(noise,2));
                end
            end
            
            
            
            if (this.NBW)
                noisecovbis = noisecovbis/this.getNoiseBanwidth();
            end
            
            o= noisecovbis;
            
            
            
        end
        
        
         function o=getSignalCovariance(this)
            %from calc_noise_cov(noise,bw_correction);       %%2D
            
            x=this.SignalKSpace;
            
            nchan = this.getNoiseNCoils();
            % Siemens method
            noisecovbis = zeros(nchan);
            for iCh = 1:nchan
                for jCh = 1:nchan
                    noisecovbis(iCh,jCh)=sum(sum(x(:,:,iCh).*conj(x(:,:,jCh))))/(size(x,1)*size(x,2));
                end
            end
            
            
            
            
            o= noisecovbis;
            
            
            
         end
        
         
         
        
        
        
        
        function noise_coeff=getNoiseCoefficients(this)
            
            noisecov=this.getNoiseCovariance;
            
            for itemp = 1:size(noisecov,1)
                for jtemp = 1:size(noisecov,1)
                    noise_coeff(itemp,jtemp) = noisecov(itemp,jtemp)/sqrt(noisecov(itemp,itemp)*noisecov(jtemp,jtemp));
                end
            end
        end
        
        
        
        function psi=getNoiseCovariancev2(this)
            
            noise=this.NoiseKSpace;
            nchan = this.getNoiseNCoils();
            
            for n=1:nchan
                X(n,:)=reshape(noise(:,:,n),1,[]);
            end
            
            psi=(1/(size(X,2)-1))*(X*X');
            
            if (this.NBW)
                psi = psi/this.getNoiseBanwidth();
            end
            
            
            
            
        end
        
        
        
        function O=prewhiteningSignal(this)
            psi=this.getNoiseCovariancev2();
            L = chol(psi,'lower');
            L_inv = inv(L);
            
            s=this.getSignalKSpace();
            nchan = this.getNoiseNCoils();
            for n=1:nchan
                X(n,:)=reshape(s(:,:,n),1,[]);
            end
            
            
            X = L_inv * X;
            
            for n=1:nchan
                O(:,:,n)=reshape(X(n,:),size(s,1),size(s,2));
            end
            
            
        end
        
        
        
        
        %         overrride
        
        function exportResults(this,fn)
            O.version='CLOUDMR2DACM20190409';
            O.author='eros.montin@gmail.com';
            
            if isempty(this.Type)
                
                O.type='DATA';
            else
                O.type=this.Type;
            end
            
            
            
            if isempty(this.subType)
                
                O.subtype='';
            else
                O.subtype=this.subType;
            end
            
            %defined in every acm method
            b=this.getParams();
            
            for t=1:size(this.Exporter,1)
                if(strcmp(this.Exporter{t,1},'image2D'))
                    im.slice=this.image2DtoJson(this.Exporter{t,3});
                    im.imageName=this.Exporter{t,2};
                    O.images(t)=im;
                    clear im;
                    
                end
                
                
            end
            
            O.settings=b;
            if (nargin>1)
            myjsonWrite(jsonencode(O),fn);
            else
                try
                    myjsonWrite(jsonencode(O),this.getOutputFileName());
                catch
                    display('error');
                end
            end
        end
        
        
        
        
        
    end
    methods (Static)
        
        
        
        
    end
    
end



