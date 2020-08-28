classdef CLOUDMR2DACMSENSE<CLOUDMR2DACMWithSensitivity
    %this is an initial class derived by the code developped at cbi.
    %sensitivity.
    %the kspace line are packed together to and the expected kspace size is
    %packed together
    %http://mriquestions.com/senseasset.html
    
    
    properties
        mimicSense=1;
        AccelerationF
        AccelerationP
        GFactorMask
        GFactorMaskID
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
            
            this.GFactorMaskID =js.GFactorMask;
            
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
        
        
        function O=isThereAMask(this)
            
            
            if strcmp(this.GFactorMaskID,'no')
                O=false;
            else
                O=true;
            end
            
        end
        
        
        
        
        function o=getSNR(this)
            %this method works on 2d images only
            noisecov=this.getNoiseCovariance();
            this.SNR=this.SNRreconEM(noisecov);
            o=this.SNR;
        end
        
        
             
        
        
        function [o, G]=getImage(this)
            [G,o]=this.getImageRiccardo();
            %max=1.8583e-06 +3.8525e-14i

        end
       

        function o=getImageEM(this)
            o=this.reconSenseImage();
            
            %3.5679e-04 + 1.8645e-11i
        end

       
         function [o,G]=getImageEMandG(this)
            o=this.getImageEM();
            G=this.reconSenseGfactor();
            %3.5679e-04 + 1.8645e-11i
        end

        
           
        
        function m=setMask(this,m)
            this.GFactorMask=m;
        end
        
        
        
        function m=getMask(this)
            
            
            %             nc=this.getNoiseNCoils;
            %             b1map = MRifft(this.getSignalKSpace,[1,2]);
            %             ref_img = sqrt(sum(abs(b1map).^2,3));
            %             b1map = b1map./repmat(ref_img,[1 1 nc]);
            %
            %
            %             [~,b]=hist(ref_img(:),1000);
            %
            %             m = ref_img > b(40); % THIS IS IMPORTANT AND WE SHOULD FIND A WAY TO GENERALIZE IT (IT NEEDS TO MASK THE OBJECT FROM THE BACKGROUND)
            %             % masktest = ones(size(masktest));
            
            
            %             m=maskb1IFFT(this.getSignalKSpace);
            
            m=this.GFactorMask;
            
        end
        
        
        
        function g=getGFactor(this)
            
            noiserawdata=this.getNoiseKSpace;
            
            nf=size(noiserawdata,1);
            np=size(noiserawdata,2);
            
            nc=this.getNoiseNCoils;
            
            noise_samples = reshape(noiserawdata,[nf*np nc]);
            noise_samples = noise_samples.';
            
            % Compute Noise Covariance Matrix from Noise Samples
            Rn = 1/size(noise_samples,2)*(noise_samples*noise_samples');
            
            % Compute "decorrelation" Matrix L
            L               = chol(Rn,'lower');
            L               = inv(L);
            
            
            
            
            b1map = MRifft(this.getSignalKSpace,[1,2]);
            
            [sf,sp,sc]=size(b1map);
            
            ref_img = sqrt(sum(abs(b1map).^2,3));
            b1map = b1map./repmat(ref_img,[1 1 nc]);
            
            if(this.isThereAMask())
                this.logIT(['maskiing inside'],'ok')
                mask=this.getMask();
                this.logIT(['seet the maskiing inside'],'ok')
                
                b1map = b1map.*repmat(mask,[1 1 nc]);
                this.logIT(['b1 masking inside'],'ok')
                
            end
            
            
            
            
            
            
            
            b1map = permute(b1map,[3,2,1]);
            
            b1map = L*b1map(:,:);
            
            
            
            b1map = reshape(b1map,sc,sp,sf);
            
            
            
            
            
            Rp = this.AccelerationP;
            Rf = this.AccelerationF;
            
            % ---------------------------------------------------
            % 2: Do SENSE Reconstruction
            %
            display('G SENSE-Reconstruction ...');
            
            
            for x=1:floor(sf./Rf)
                for y=1:floor(sp./Rp)
                    
                    s_temp=squeeze(b1map(:,y:floor(sp./Rp):sp,x:floor(sf./Rf):sf));   %Gather the aliased pixels into the sensitivity matrix
                    %         s=squeeze(b1map(:,y:sp./R:sp,x));   %Gather the aliased pixels into the sensitivity matrix
                    
                    s = reshape(s_temp,[nc size(s_temp,2)*size(s_temp,3)]);
                    u=pinv(s);                          %psuedoinverse of coil sensitivity matrix
                    
                    
                    
                    g(y:floor(sp./Rp):sp,x:floor(sf./Rf):sf) = reshape(sqrt(abs(diag(pinv(s'*s)).*diag(s'*s))),[size(s_temp,2) size(s_temp,3)]);   %Calculate g-factor using
                    %         g_sense(y:sp./R:sp,x)=sqrt(abs(diag(pinv(s'*s)).*diag(s'*s)));   %Calculate g-factor using formula from Pruessmann, et al
                    
                end
            end
            
            g=permute(g,[2,1]);
        end
        
        
               
        
              
        
        
             
        
        
        
        function snr= SNRreconEM(this,noisecov)
            
            if (this.mimicSense)
                
                %create the fake image
                KIM=this.mimic2DSENSEfromFullysampled(this.getSignalKSpace,this.AccelerationF,this.AccelerationP);
                IM=this.get2DKSIFFT(KIM);
                
                %ifft in the image domain
                %correct 10/01/2019
                if ((mod(this.AccelerationF,2)==0) && this.AccelerationF>1)
                    IM=ifftshift(IM,1);
                end
                
                if (mod(this.AccelerationP,2)==0 && this.AccelerationP>1)
                    IM=ifftshift(IM,2);
                end
                
     
            else
                KIM=this.getSignalKSpace();
                IM=this.get2DKSIFFT(KIM);
            end
                    
                S=this.getSensitivityMatrix();
                
                
                
                Acceleratedsize=[size(IM,1) size(IM,2) ];
                
                Realsize=[size(S,1) size(S,2) ];
                
                nchan=size(IM,3);
                
                snr=NaN(Realsize);
                
                for af=1:Acceleratedsize(1)
                    for ap=1:Acceleratedsize(2)
                        
                        freq_set=af:Acceleratedsize(1):Realsize(1);
                        phase_set=ap:Acceleratedsize(2):Realsize(2);
                        Pfov=reshape(IM(af,ap,:),[1 nchan]);
                        
                        NF=length(freq_set);
                        NP=length(phase_set);
                        
                        %get the sensitivity of the combined pixels
                        s_matrix = S(freq_set,phase_set,:);
                        s_matrix = reshape(s_matrix,[NF*NP nchan]);
                        s_matrix =s_matrix.';
                        
                        u_matrix = inv((s_matrix')*inv(noisecov)*s_matrix)*(s_matrix')*inv(noisecov);
                        X=sqrt(2)*(u_matrix)*Pfov.'./diag(sqrt((u_matrix)*noisecov*(u_matrix')));

                       
                        snr(freq_set,phase_set)=reshape(X,[NF NP]);
                    end
                end
                
                
                
                
        
            
        end
        
        
        
        
        function G= reconSenseGfactor(this)
             
            
                    
                S=this.getSensitivityMatrix();
                
                
                noisecov=this.getNoiseCovariance();
                
     
                Realsize=[size(S,1) size(S,2) ];
                
                acc=[this.AccelerationF this.AccelerationP];
                Acceleratedsize=Realsize./acc;
                
                nchan=size(S,3);
                
                G=NaN(Realsize);
                
                for af=1:Acceleratedsize(1)
                    for ap=1:Acceleratedsize(2)
                        
                        freq_set=af:Acceleratedsize(1):Realsize(1);
                        phase_set=ap:Acceleratedsize(2):Realsize(2);
                        
                        NF=length(freq_set);
                        NP=length(phase_set);
                        
                        %get the sensitivity of the combined pixels
                        s_matrix = S(freq_set,phase_set,:);
                        s_matrix = reshape(s_matrix,[NF*NP nchan]);
                        s_matrix =s_matrix.';
                        
                         G(freq_set,phase_set) =  reshape( sqrt(acc(1)*acc(2)*diag(inv((s_matrix')*inv(noisecov)*s_matrix)).*diag((s_matrix')*inv(noisecov)*s_matrix)), [length(freq_set) length(phase_set)]);


                        %image(freq_set,phase_set)=reshape(X,[NF NP]);
                    end
                end
                
                
        end
        
         function image= reconSenseImage(this)
             %from riccardo code SNR batch graham
            
            if (this.mimicSense)
                
                %create the fake accellerated data image
                KIM=this.mimic2DSENSEfromFullysampled(this.getSignalKSpace,this.AccelerationF,this.AccelerationP);
                
                IM=this.get2DKSIFFT(KIM);
                
                            %ifft in the image domain
                %correct 10/01/2019
                if ((mod(this.AccelerationF,2)==0) && this.AccelerationF>1)
                    IM=ifftshift(IM,1);
                end
                
                if (mod(this.AccelerationP,2)==0 && this.AccelerationP>1)
                    IM=ifftshift(IM,2);
                end
                
                
     
            else
                KIM=this.getSignalKSpace();
                IM=this.get2DKSIFFT(KIM);
            end
                    
                S=this.getSensitivityMatrix();
                
                
                noisecov=this.getNoiseCovariance();
                
                Acceleratedsize=[size(IM,1) size(IM,2) ];
                
                Realsize=[size(S,1) size(S,2) ];
                
                nchan=size(IM,3);
                
                image=NaN(Realsize);
                
                for af=1:Acceleratedsize(1)
                    for ap=1:Acceleratedsize(2)
                        
                        freq_set=af:Acceleratedsize(1):Realsize(1);
                        phase_set=ap:Acceleratedsize(2):Realsize(2);
                        Pfov=reshape(IM(af,ap,:),[1 nchan]);
                        
                        NF=length(freq_set);
                        NP=length(phase_set);
                        
                        %get the sensitivity of the combined pixels
                        s_matrix = S(freq_set,phase_set,:);
                        s_matrix = reshape(s_matrix,[NF*NP nchan]);
                        s_matrix =s_matrix.';
                        
                        u_matrix = inv(s_matrix'*inv(noisecov)*s_matrix)*((s_matrix')*inv(noisecov));
                        X=(u_matrix)*Pfov.';
                        
                         image(freq_set,phase_set) = reshape(X,[NF NP]);

                        %image(freq_set,phase_set)=reshape(X,[NF NP]);
                    end
                end
                
                
                
                
        
%              figure;
%              
%              imshow(image,[]);colorbar;
%              title(['EROS RECON ' num2str(this.AccelerationF) ' ' num2str(this.AccelerationP)]);
         end
        
         
         
         function [g sense_image]=getImageRiccardo(this)
            
            noiserawdata=this.getNoiseKSpace;
            
            nf=size(noiserawdata,1);
            np=size(noiserawdata,2);
            
            nc=this.getNoiseNCoils;
            
            noise_samples = reshape(noiserawdata,[nf*np nc]);
            noise_samples = noise_samples.';
            
            % Compute Noise Covariance Matrix from Noise Samples
            Rn = 1/size(noise_samples,2)*(noise_samples*noise_samples');
            
            % Compute "decorrelation" Matrix L
            L               = chol(Rn,'lower');
            L               = inv(L);
            
            
            
            
            b1map = this.getSensitivityMatrix();
            
            if(this.isThereAMask())
                this.logIT(['maskiing inside'],'ok')
                mask=this.getMask();
                this.logIT(['seet the maskiing inside'],'ok')
                
                b1map = b1map.*repmat(mask,[1 1 nc]);
                this.logIT(['b1 masking inside'],'ok')
                
            end
            
            
            
            
            
            [sf,sp,sc]=size(b1map);
           
            
            b1map = permute(b1map,[3,2,1]);
            
            b1map = L*b1map(:,:);
            
            
            
            b1map = reshape(b1map,sc,sp,sf);
            
            if (this.mimicSense)
                
                %create the fake accellerated data image
                KIM=this.getSignalKSpace;
             
                
             nf=size(KIM,1);
            np=size(KIM,2);
            
            raw_data = permute(KIM,[3,2,1]);
            raw_data = L*raw_data(:,:);
            raw_data = reshape(raw_data,nc,np,nf);
            
            end
                

            
            
            
            R=this.AccelerationP;
            
    k_temp              = zeros(size(b1map));
    k_temp(:,1:R:np,:)  = raw_data(:,1:R:np,:);
    
    % Generate aliased multi-channel images
    aliased_image = ifftshift(ifft(ifftshift(k_temp,3),[],3),3);
    aliased_image = ifftshift(ifft(ifftshift(aliased_image,2),[],2),2);
    
    % Do Reconstruction and g-Factor calculation
    % [sense_image,g_sense] = opensense(aliased_image(:,1:np/R,:),b1map,R);
    
    imfold = aliased_image(:,1:floor(np/R),:);
    
    
    
    
            
            
            
            Rp = this.AccelerationP;
            Rf = this.AccelerationF;
            
            % ---------------------------------------------------
            % 2: Do SENSE Reconstruction
            %
            display('SENSE-Reconstruction ...');
            
            
            for x=1:floor(sf/Rf)
                for y=1:floor(sp/Rp)
                    
                    
                    s_temp=squeeze(b1map(:,y:floor(sp/Rp):sp,x:floor(sf/Rf):sf));   %Gather the aliased pixels into the sensitivity matrix
                    %         s=squeeze(b1map(:,y:sp./R:sp,x));   %Gather the aliased pixels into the sensitivity matrix
                    
                    s = reshape(s_temp,[nc size(s_temp,2)*size(s_temp,3)]);
                    u=pinv(s);                          %psuedoinverse of coil sensitivity matrix
                    
                                
            
            pp=u*squeeze(imfold(:,y,x));        %do the reconstruction of this set of pixels
            sense_image(y:floor(np/R):np,x)=pp;        
            
                    
                    g(y:floor(sp./Rp):sp,x:floor(sf./Rf):sf) = reshape(sqrt(abs(diag(pinv(s'*s)).*diag(s'*s))),[size(s_temp,2) size(s_temp,3)]);   %Calculate g-factor using
                    %         g_sense(y:sp./R:sp,x)=sqrt(abs(diag(pinv(s'*s)).*diag(s'*s)));   %Calculate g-factor using formula from Pruessmann, et al
                    
                end
            end
            
            g=permute(g,[2,1]);
            
            sense_image=permute(sense_image,[2,1]);
         end
        
         
        
        
        
        
        
        
        
        
        
    end
end


