classdef CLOUDMR2DPMR<CLOUDMROutput
    %main class of array combining methods, the constructor is ovewritten by
    %the class constructor
    %the code was based on Riccardo Lattanzi code commented in the foot of
    %thei script
    
    %step calulate noise correlation factors
    
    properties
        
        reconstructor %Real acm class with all the data
        
        NR=100
    end
    
    methods
        
        function this=CLOUDMR2DPMR(s)
            this.Type='PMR';
            if nargin>0
                this.setReconstructionmethods(s);
            end
        end
        
        function setReconstructionmethods(this,s)
            switch(lower(s))
                case 'rss'
                    this.reconstructor=CLOUDMR2DACMRSS();
                    
            end
        end
        
        
        function setReconstructor(this,R)
            this.reconstructor=R;
        end
        
        
        function readConf(this,js)
            
            this.NR=js.NR;
            
        end
        
        
        
        function O=getParams(this)
            
            O.Type=this.Type;
            O.NR=this.NR;
            
        end
        
        
        function setNoiseKSpace(this,f)
            % 2DKspace
            this.reconstructor.setNoiseKSpace(f);
            
        end
        
        function o =getNoiseKSpace(this)
            % 2DKspace
            o = this.reconstructor.getNoiseKSpace();
        end
        
        
        function setSignalKSpace(this,f)
            %2Dkspace
            this.reconstructor.setSignalKSpace(f);
            
        end
        
        function o=getSignalKSpace(this)
            o=this.reconstructor.getSignalKSpace();
        end
        
        
        function o=getNoiseCovariance(this)
            o= this.reconstructor.getNoiseCovariance();
        end
        
        
        
        
        function [o, o2]=PseudoMRS(this)
            try
                NR=this.NR;
                %this method works on 2d images only
                noisecov=this.getNoiseCovariance();
                
                %riccardo lattanzi
                [V,D] = eig(noisecov);
                corr_noise_factor = V*sqrt(D)*inv(V);
                
                %calculate the sensitivity maps once.
        
                
                
                if (strcmp( class(this.reconstructor),'CLOUDMR2DACMSENSE') || this.reconstructor.needsSensitivity())
                    S=this.reconstructor.getSensitivityMatrix();
                    this.reconstructor.setSensitivityMatrix(S);
                end
                
                %reconstruct the ref image
                 K=this.reconstructor.getSignalKSpace();
                 this.reconstructor.setSignalKSpace(K);
                 referenceimage=this.reconstructor.getImage();
                
                
                for r=1:NR
                    n=this.getPseudoNoise(size(K),corr_noise_factor);
%                     X=abs(n(:));
%                     display([num2str(min(X),3) ', ' num2str(max(X),3) ', ' num2str(mean(X),3)]);
                    
                    %noise must be sampled like the sense
                    if(this.reconstructor.isAccelerated)
                        n=n.*(K~=0);
                        
%                         if(isprop(this.reconstructor,'Autocalibration'))
%                         n=undersamplemSense2D(n,this.reconstructor.AccelerationF,this.reconstructor.AccelerationF,this.reconstructor.Autocalibration);
%                         else
%                             n=undersamplemSense2D(n,this.reconstructor.AccelerationF,this.reconstructor.AccelerationF);
%                         end
                    end
                    
                    this.reconstructor.setSignalKSpace(K+n);
                    % this.reconstructor.setSignalKSpace(K);
                    
                 %   R(:,:,r)=this.reconstructor.getSNR();
                 %   this.reconstructor.resetSNR();
                    Re(:,:,r)=this.reconstructor.getImage();
                end
                
                
                
                o2=std(Re,0,3);
                o=referenceimage./o2;
              %  o2=mean(R,3);
                
                
                this.Exporter=[this.Exporter;[{'image2D'},{'SNR '},{o}]];
                this.Exporter=[this.Exporter;[{'image2D'},{'STD'},{o2}]];
                this.logIT('PSEUDO MR calculated','ok');
            catch
                this.logIT('cannot calculate Pseudo MR','ko');
                
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
            b=this.reconstructor.getParams();
            b.NR=this.NR;
            
            for t=1:size(this.Exporter,1)
                if(strcmp(this.Exporter{t,1},'image2D'))
                    im.slice=this.image2DtoJson(this.Exporter{t,3});
                    im.imageName=this.Exporter{t,2};
                    O.images(t)=im;
                    clear im;
                    
                end
                
                
            end
            
            O.settings=b;
            myjsonWrite(jsonencode(O),fn);
        end
        
        
        
        
        
        
        
        
    end
    
    
    methods (Static)
        function gaussian_whitenoise=getPseudoNoise(msize,corr_noise_factor)
            %msize (freq,phase,coil)
            
            %dunno why... ask Riccardo
            N=sqrt(0.5)*(randn(msize)+1i*randn(msize));
            
%             for n=1:msize(3)
%                 X(n,:)=reshape(N(:,:,n),1,[]);
%             end
%             
%             
%             X = noise_corr_coeff * X;
%             
%             for n=1:msize(3)
%                 o(:,:,n)=reshape(X(n,:),msize(1),msize(2));
%             end
            

                nrow=msize(1);
                ncol=msize(2);
                nchan=msize(3);
                
                gaussian_whitenoise = reshape(N,[nrow*ncol nchan]);
                gaussian_whitenoise = corr_noise_factor*(gaussian_whitenoise.');
                gaussian_whitenoise = reshape((gaussian_whitenoise.'),[nrow ncol nchan]);
             
                
                
                
                
            
            
        end
        
        
    end
end



% function [snr,g,img] = calc_snr_pseudomr(signalrawdata,noisecov,nreplicas,nchan,recon_method,compute_g,acc,simple_sens)
%
% disp(['     Pseudo multiple replicas beginning (' num2str(nreplicas) ' replicas) ...']);
% nrow = size(signalrawdata,1);
% ncol = size(signalrawdata,2);
%
% if compute_g == 0
%     g = [];
% else
%     g = zeros(size(signalrawdata));
% end
%
% if nchan == 1
%     image_stack = zeros([size(signalrawdata) nreplicas]);
%     img_matrix = MRifft(signalrawdata,[1,2]);
%     img_matrix = img_matrix*sqrt(nrow*ncol);
%     for ireplica = 1:nreplicas
%         gaussian_whitenoise = sqrt(noisecov)*randn(size(signalrawdata)); % it's the noise bandwidth in the single-channel case
%         noisy_kspace = signalrawdata + gaussian_whitenoise;
%         image_stack(:,:,ireplica) = MRifft(noisy_kspace,[1,2])*sqrt(nrow*ncol);
%     end
%     image_noise = std(real(image_stack),0,3);
%     %     image_signal = mean(real(image_stack),3);
%     %     snr = image_signal./image_noise;
%     snr = real(img_matrix)./image_noise;
% else
%     switch recon_method
%         case 'opt'
%             [V,D] = eig(noisecov);
%             corr_noise_factor = V*sqrt(D)*inv(V);
%
%             img_matrix = MRifft(signalrawdata,[1,2]);
%             img_matrix = img_matrix*sqrt(nrow*ncol);
%
%             if simple_sens
%                 reference_image = sqrt(sum(abs(img_matrix).^2,3));
%                 coilsens_set = img_matrix./repmat(reference_image,[1 1 nchan]);
%             else
%                 [recon,coilsens_set]=adapt_array_2d(img_matrix);
%             end
%             disp('***  ...coil sensitivities computed...');
%
%             image_stack = zeros([nrow ncol nreplicas]);
%
%
%
%             for ireplica = 1:nreplicas
%                 %         gaussian_whitenoise = (rand(size(signalrawdata))-.5);
%                 %         gaussian_whitenoise = randn(size(signalrawdata));
%                 gaussian_whitenoise = sqrt(0.5)*(randn(size(signalrawdata)) +1i*randn(size(signalrawdata)));
%                 gaussian_whitenoise = reshape(gaussian_whitenoise,[nrow*ncol nchan]);
%                 gaussian_whitenoise = corr_noise_factor*(gaussian_whitenoise.');
%                 gaussian_whitenoise = reshape((gaussian_whitenoise.'),[nrow ncol nchan]);
%                 noisy_kspace = signalrawdata + gaussian_whitenoise;
%                 noisy_img = MRifft(noisy_kspace,[1,2]);
%                 noisy_img = noisy_img*sqrt(nrow*ncol);
%
%                 for irow = 1:size(signalrawdata,1)
%                     for icol = 1:size(signalrawdata,2)
%                         s_matrix = squeeze(coilsens_set(irow,icol,:));
%                         image_stack(irow,icol,ireplica) = abs((s_matrix')*inv(noisecov)*squeeze(noisy_img(irow,icol,:)));
%                         if ireplica == 1
%                             img(irow,icol) = abs((s_matrix')*inv(noisecov)*squeeze(img_matrix(irow,icol,:)));
%                         end
%                     end
%                 end
%                 disp(['    Replica #' num2str(ireplica) ' done']);
%             end
%             image_noise = std(real(image_stack),0,3);
%             %     image_signal = mean(real(image_stack),3);
%             %     snr = image_signal./image_noise;
%             snr = real(img)./image_noise;
%     end
% end

