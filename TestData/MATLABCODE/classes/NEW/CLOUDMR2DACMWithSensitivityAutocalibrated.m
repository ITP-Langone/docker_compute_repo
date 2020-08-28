classdef CLOUDMR2DACMWithSensitivityAutocalibrated<CLOUDMR2DACMWithSensitivity
    %SensitivityMode can be calculateFromImage of CalculateFromNewDAta
    %CoilSenseitivityMap is the actual Sensitivitymap used to calculate the SNR
    %RealCoilSensitivityMap is the MROPTDATA with the sampled sensitivity
    %method
    %SensitivityCalculationMethod, a string {'simplesense','adaptive','zerofilling','bodycoil'}
    %To get SNR we neeed to fet S (sensitivity) and Noisecovariance matrix
    %v25022020
    
    properties
        Autocalibration
    end
    
    methods
        
        
        function o=getSensitivityMatrix(this)
            
            this.logIT(['sensitivity has been requested'],'ok');
            
            if (isempty(this.CoilSensitivityMap))
                this.logIT(['Coil sensitivity map has never been calculated'],'ok');
                %                     case 'self' %the same image   sens_matrix= this.getKSpace2DIFFT('signal');
                %                     case 'file' %im=MROPTRawData(this.SourceCoilSensitivityMap);
                %                         sens_matrix= im.reduceKSpace2DSliceIFFT(c,r,s);
                %                 end
                
                if (~isempty(this.SourceCoilSensitivityMap))
                    this.logIT(['a Source Coil sensitivity map has been correctly set so i can calculate the senstivity map'],'ok');
                    
                    
                    
                    %                       img_matrix = MRifft(signalrawdata,[1,2]);
                    %     % reconstruct individual coils' images and apply FFT scale factor
                    %     % iFFT scales data by 1/N, so I need to scale back, as the noise covariance
                    %     % matrix is calculated in k-space (not Fourier transformed)
                    %     img_matrix = img_matrix*sqrt(nrow*ncol);
                    %
                    %  reference_image = sqrt(sum(abs(img_matrix).^2,3));
                    %                     coilsens_set = img_matrix./repmat(reference_image,[1 1 nchan]);
                    %
                    sens_matrix=this.get2DKSIFFT(this.SourceCoilSensitivityMap);
                    
                    
                    nchan=this.getSignalNCoils;
                    
                    switch(lower(this.SensitivityCalculationMethod))
                        case {'bartsense'}
                            %   https://mrirecon.github.io/bart/examples.html#2
                            SOURCE=this.bartMy2DKSpace(this.SourceCoilSensitivityMap());
                            try
                                c=['caldir ' num2str(this.Autocalibration)];
                                sens = bart(c, SOURCE); %sense
                                % sens = bart('slice 4 0', calib);
                                coilsens_set = this.debartMy2DKSpace(sens);
                            catch
                                coilsens_set = espirit_sensitivitymap(this.SourceCoilSensitivityMap,this.Autocalibration);
                                
                            end
                        case {'espirit','espiritaccelerated'}
                            SOURCE=this.bartMy2DKSpace(this.SourceCoilSensitivityMap());
                            %[calib ~] = bart(['ecalib  -r ' num2str(this.Autocalibration) ' -m 2'], SOURCE); %sense
                            [calib, ~] = bart(['ecalib  -r ' num2str(this.Autocalibration) ], SOURCE); %sense
                            sens = bart('slice 4 0', calib);
                            coilsens_set = this.debartMy2DKSpace(sens);
                            
                        case {'espiritv1'}
                            %in this case sens_matrix is the full image
                            this.logIT(['sensitivity map calculated as espirit'],'ok');
                            
                            coilsens_set = espirit_sensitivitymap(this.SourceCoilSensitivityMap,this.Autocalibration);
                            
                            
                        case {'simplesense','internal reference','inner'}
                            %in this case sens_matrix is the full image
                            this.logIT(['sensitivity map calculated as simplesense'],'ok');
                            reference_image  = sqrt(sum(abs(sens_matrix).^2,3));
                            coilsens_set = sens_matrix./repmat(reference_image,[1 1 nchan]);
                        case 'adaptive'
                            %    %in this case sens_matrix is the fiull
                            %    size image
                            this.logIT(['sensitivity map calculated as aspative'],'ok');
                            
                            [~,coilsens_set] = adapt_array_2d(sens_matrix,this.getSignalCovariance());
                        case 'bodycoil'
                            
                            %in this case sens_matrix is the BC
                            reference_image=this.get2DKSIFFT(this.getSignalKSpace());
                            switch( this.getSourceCoilSensitivityMapNCoils)
                                
                                
                                case 1
                                    coilsens_set = reference_image/repmat(sens_matrix,[1 1 nchan]);
                                case 2
                                    %old                                     BCIM=(sens_matrix(:,:,1)+1i*(sens_matrix(:,:,2)))/sqrt(2);
                                    center_phase_1 = angle(sens_matrix(floor(end/2),floor(end/2),1));
                                    center_phase_2 = angle(sens_matrix(floor(end/2),floor(end/2),2));
                                    
                                    image_1 = sens_matrix(:,:,1)*exp(-1i*center_phase_1);
                                    image_2 = sens_matrix(:,:,2)*exp(-1i*center_phase_2);
                                    
                                    %1 BCIM = abs((image_1 + 1i*image_2))/sqrt(2);
                                    
                                    %2 BCIM=sqrt(abs(sens_matrix(:,:,1)).^2 + abs(sens_matrix(:,:,2)).^2);
                                    
                                    BCIM =abs(image_1 + image_2)/sqrt(2);
                                    
                                    coilsens_set = reference_image./repmat(abs(BCIM),[1 1 nchan]);
                                otherwise
                                    %in this case 1th kspace of the bodycoil
                                    coilsens_set = reference_image./repmat(sens_matrix(:,:,1),[1 1 nchan]);
                            end
                            
                            %                             coilsens_set=coilsens_set./prctile(coilsens_set(:),99);
                            
                            
                            %                             coilsens_set(coilsens_set>1)=1;
                            this.logIT(['sensitivity map calculated as BodyCoil'],'ok');
                            
                            %matlab max function applied to a complex vector compute its largest element, that is, the element with the largest magnitude.
                            %it can be proven that complex numbers cannot be ordered (under the definition of an ordered field). That means that you cannot compare complex numbers. As per the documentation, < (and co.) only compare the real part of a number, whereas min returns the complex number with the smallest magnitude.
                            
                            
                            %                               for nc=1:nchan
                            %                                   PMax=prctile(reshape(coilsens_set(:,:,nc),[],1),100);
                            %                                     PMin=prctile(reshape(coilsens_set(:,:,nc),[],1),0);
                            %                                     coilsens_set(:,:,nc)=(coilsens_set(:,:,nc)-(ones(size(coilsens_set,1),size(coilsens_set,2)).*PMin))./(ones(size(coilsens_set,1),size(coilsens_set,2)).*PMax);
                            %
                            %                               end
                            %
                            for na=1:size(coilsens_set,1)
                                for nb=1:size(coilsens_set,2)
                                    V=[coilsens_set(na,nb,:)];
                                    PMax=prctile(reshape(V,[],1),100);
                                    PMin=prctile(reshape(V,[],1),0);
                                    coilsens_set(na,nb,:)= (V-PMin)./PMax;
                                end
                            end
                            
                            
                        otherwise
                            this.logIT(['sensitivity ' lower(this.SensitivityCalculationMethod)  'calculation method not set '],'ko');
                            return
                            
                    end
                    
                    
                    
                    if (this.SourceCoilSensitivityMapSmooth)
                        for aa=1:size(coilsens_set,3)
                            coilsens_set(:,:,aa)=medfilt2(real(coilsens_set(:,:,aa)),[3 3],'symmetric')+1i*medfilt2(imag(coilsens_set(:,:,aa)),[3 3],'symmetric');
                        end
                        
                    end
                    
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %                      for na=1:size(coilsens_set,1)
                    %                                   for nb=1:size(coilsens_set,2)
                    %                                  V=[coilsens_set(na,nb,:)];
                    %                                     PMax=prctile(reshape(V,[],1),100);
                    %                                     PMin=prctile(reshape(V,[],1),0);
                    %                                      coilsens_set(na,nb,:)= (V-PMin)./PMax;
                    %                                   end
                    %                      end
                    
                    
                    %                     SS=coilsens_set./prctile(coilsens_set(:),99);
                    %                     SS(SS>1)=1;
                    this.CoilSensitivityMap=coilsens_set;
                    
                    this.logIT(['start sensitivity map export'],'ok');
                    
                    if(this.SaveCoils)
                        for t=1:nchan
                            this.addToExporter('image2D',['Coil Sens. #' sprintf('%03d',t) ],squeeze(coilsens_set(:,:,t)));
                            
                        end
                        this.logIT(['sensivities request'],'ok');
                    else
                        this.logIT(['no sensivities request'],'ok');
                    end
                    
                    this.logIT(['stop sensitivity map export'],'ok');
                    
                else
                    
                    this.logIT(['source coil map not set'],'ko');
                    
                end
                
            end
            o=this.CoilSensitivityMap;
            
        end
        
        
        
        function o=testSensitivityMatrixvalidity(this)
            ss= size(this.getSensitivityMatrix());
            is= size(this.getSignalKSpace());
            
            if sum(ss(1:2)== is(1:2))==2
                o=true;
                this.logIT('sensitivity is valid','ok')
            else
                o=false;
                this.logIT('sensitivity is not valid (size differencies)','ok')
                
            end
            
            
            
        end
        
        
        function setSourceCoilSensitivityMap(this,IM)
            %expect a 2D coil sens map
            this.SourceCoilSensitivityMap=IM;
            this.SourceCoilSensitivityMapNCoils=size(IM,3);
        end
        
        
        function O=getSourceCoilSensitivityMapID(this)
            %expect a 2D coil sens map
            O=this.SourceCoilSensitivityMapID;
            
        end
        
        
        
        function o=getSourceCoilSensitivityMapNCoils(this)
            o=this.SourceCoilSensitivityMapNCoils();
        end
        
        
        function setSensitivityCalculationMethod(this,x)
            this.SensitivityCalculationMethod=x;
        end
        
        function x=getSensitivityCalculationMethod(this)
            x=this.SensitivityCalculationMethod;
        end
        
        
        
        
        
        
    end
end

