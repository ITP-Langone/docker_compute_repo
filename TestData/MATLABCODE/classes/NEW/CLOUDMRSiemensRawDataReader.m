classdef CLOUDMRSiemensRawDataReader<CLOUDMRRD
    
    properties
        DATA
        ICE_FACTOR=3200;
           computePF=0
    end
    
    methods
        function this = CLOUDMRSiemensRawDataReader(f)
            %data are collected and if data is a structure the possible
            %(image) (noise) and refscan will have is own hdr
            
            
%             DATA=mapVBVD(f,'doAverage','removeOS');
            DATA=mapVBVD(f,'removeOS');
            
%             DATA=mapVBVD(f);
            
            if isstruct(DATA) %single raid
                
                try;this.DATA.image=DATA.image();catch;end
                try;this.DATA.imagehdr=DATA.hdr;catch;end
                try;this.DATA.noise=DATA.noise();catch;end
                try;this.DATA.noisehdr=DATA.hdr;catch;end
                
                
            elseif iscell(DATA) %multi raid
                x=2;%=find(cellfun(@(h) isfield(h,'image'),DATA));
                if ~isempty(x)
                    this.DATA.image= DATA{x}.image();
                    this.DATA.imagehdr=DATA{x}.hdr;
                    kdata_dwelltime = DATA{x}.hdr.Meas.RealDwellTime(2);
                end
                
                x=1; %=find(cellfun(@(h) isfield(h,'noise'),DATA));
                if ~isempty(x)
%                     theres's a dweltime also for noise but we decided to
%                     fix it to 5000 Riccardo 
%                      knoise_dwelltime=DATA{x}.hdr.Meas.RealDwellTime(2);
%                       agreed with Lattanzi on 05/23/2020
                    knoise_dwelltime = 5000;
                    correction_factor = sqrt(knoise_dwelltime/kdata_dwelltime);
                   
                    this.DATA.noise= DATA{x}.noise() *correction_factor;
                    this.DATA.noisehdr= DATA{x}.hdr;
                    

                    
                end
                
%                 if ~isempty(x)
%                     this.DATA.internalnoise= DATA{x}.noise();
%                     this.DATA.internalnoisehdr= DATA{x}.hdr;
%                     
%                 end
                
                
                
            end
            
            
        end
        
        
        
        function o=getNCoils(this)
            
            if isempty(this.DATA)
                this.logIT('any problems reading the number of coils data is empty','ko');
            else
                try
                    o = this.DATA.image.NCha;
                    this.logIT(['file ' this.getFilename() ' has ' num2str(o) ' channels '], 'ok');
                catch
                    this.logIT('any problems reading the number of coils','ko');
                    o = 1;
                end
            end
        end
        
        function o=getNRepetition(this)
            
            if isempty(this.DATA)
                this.logIT('any problems reading the number of repetitions data is empty','ko');
            else
                try
                    o = this.DATA.image.NRep;
                    this.logIT(['file ' this.getFilename() ' is repeated ' num2str(o) ' times'], 'ok');
                catch
                    this.logIT('any problems reading the number of repetition','ko');
                    o = 1;
                end
            end
        end
        
        
        
        function o=getNAverage(this)
            
            if isempty(this.DATA)
                this.logIT('any problems reading the number of avg data is empty','ko');
            else
                try
                    o = this.DATA.image.NAve;
                    this.logIT(['file ' this.getFilename() 'has ' num2str(o) ' average'], 'ok');
                catch
                    this.logIT('any problems reading the number of average','ko');
                    o = 1;
                end
            end
        end
        
        function o=getNContrast(this)
            
            if isempty(this.DATA)
                this.logIT('any problems reading the number of contrast data is empty','ko');
            else
                try
                    o = this.DATA.image.NEco;
                    this.logIT(['file ' this.getFilename() 'has ' num2str(o) ' contrast'], 'ok');
                catch
                    this.logIT('any problems reading the number of constrast','ko');
                    o = 1;
                end
            end
        end
        
        function o=getNSlice(this)
            
            if isempty(this.DATA)
                this.logIT('any problems reading the number of Slice data is empty','ko');
            else
                try
                    o = this.DATA.image.NSli;
                    this.logIT(['file ' this.getFilename() ' has ' num2str(o) ' Slices'], 'ok');
                catch
                    this.logIT('any problems reading the number of slices','ko');
                    o = 1;
                end
            end
        end
        
        
        function o=getTrajectory(this)
            
            
            o='notimplemented';
        end
        
        
        
        
%         function o=getEncodedSpaceInfo(this)
%             o=false;
%             try
%                 
%                 %% Encoding and reconstruction information
%                 % Matrix size
%                 o.Nx = this.Hdr.encoding.encodedSpace.matrixSize.x;
%                 o.Ny = this.Hdr.encoding.encodedSpace.matrixSize.y;
%                 o.Nz = this.Hdr.encoding.encodedSpace.matrixSize.z;
%                 
%                 % Field of View
%                 o.FOVx = this.Hdr.encoding.encodedSpace.fieldOfView_mm.x;
%                 o.FOVy = this.Hdr.encoding.encodedSpace.fieldOfView_mm.y;
%                 o.FOVz = this.Hdr.encoding.encodedSpace.fieldOfView_mm.z;
%             catch
%                 this.logIT('Encoded space not yet implemented','ko');
%             end
%         end
%         
%         
%         function o=getReconSpaceInfo(this)
%             o=false;
%             try
%                 %% Encoding and reconstruction information
%                 % Matrix size
%                 o.Nx = this.Hdr.encoding.reconSpace.matrixSize.x;
%                 o.Ny = this.Hdr.encoding.reconSpace.matrixSize.y;
%                 o.Nz = this.Hdr.encoding.reconSpace.matrixSize.z;
%                 
%                 % Field of View
%                 o.FOVx = this.Hdr.encoding.reconSpace.fieldOfView_mm.x;
%                 o.FOVy = this.Hdr.encoding.reconSpace.fieldOfView_mm.y;
%                 o.FOVz = this.Hdr.encoding.reconSpace.fieldOfView_mm.z;
%             catch
%                 this.logIT('Recon space not yet implemented','ko');
%                 
%             end
%             
%         end
        
        
        
        function o=readImageKSpace(this)
            
            K=this.DATA.image();
            size(K)
            %permute freq,phase,coils
            KO=this.mapvbvdtoCLOUDMRRD(K);
            
            clear K;
            %can be initialized
            
            %pocs
            if( this.isPF(this.DATA.imagehdr)  && this.computePF)
                for a=1:this.getNAverage() %for each avg
                    for b=1:this.getNRepetition() %for each repetirion
                        for c=1:this.getNContrast %for each contrast
                            for d=1:this.getNSlice %for each slice
                                
                                
                                [K(a,b,c,:,:,d,:)]=this.resamplePF(this.DATA.imagehdr,squeeze(KO(a,b,c,:,:,d,:)),this.getNCoils());
                                
                            end
                        end
                    end
                end %avg
                o=K;%*this.ICE_FACTOR;
                
            else
                o=KO;%*this.ICE_FACTOR;
            end
            
            
            
            
        end
        
        
        function o=readNoiseKSpace(this)
            K=this.DATA.noise();
            size(K)
            %permute freq,phase,coils
            KO=this.mapvbvdtoCLOUDMRRD(K);
            clear K;
            
            o=KO;%*this.ICE_FACTOR;
            
        end
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
    end
    
    methods(Static)
        
        function E=getPF(Fi,Fo)
            E=[Fi:Fo];
            
        end
        
        
        
        function O=isPF(hdr)
            %is there partial furier
            E=hdr.Config.PhaseEncodingLines;
            
            Er=hdr.Config.RawLin;
            
            if(E ~= Er)
                O=1;
            else
                O=0;
            end
        end
        
        
        function O=resamplePF(hdr,K,nC)
            %(hdr,Kspace,numberofcoils)
            if(CLOUDMRSiemensRawDataReader.isPF(hdr))
                
                E=hdr.Config.PhaseEncodingLines;
                RE=hdr.Config.RawLin;
                
                
                T=E-RE;
                nx= (1:RE)+T;
                O=zeros(size(K,1),E,1,nC); %posso farlo meglio
                O(:,nx,:,:)=K;
                
                
                [~, f] = pocs( permute(squeeze(O(:,:,1,:)),[3 1 2]), 200 );
                %add a dimension from 3d (coil,freq,ph) to 4D (freq,phase,slice,coil)
                O=permute(reshape(f,nC,size(f,2),size(f,3),1),[2 3 4 1]);
                
                
            end
        end
        
        
        
        
        
        function KO=mapvbvdtoCLOUDMRRD(K)
            % Order of raw data:
            %  1) Columns
            %  2) Channels/Coils
            %  3) Lines
            %  4) Partitions
            %  5) Slices
            %  6) Averages
            %  7) (Cardiac-) Phases
            %  8) Contrasts/Echoes
            %  9) Measurements
            % 10) Sets
            % 11) Segments
            % 12) Ida
            % 13) Idb
            % 14) Idc
            % 15) Idd
            % 16) Ide
            
            %to
            %  nAvg,nContrasts,nReps,enc_Nx, enc_Ny, nSlices, nCoils
            
            
            
            
            %             if numel(size(K))==16
            %             TRANSLATESIEMENSTOISMRMRD=[6, 16, 15, 1, 3, 5, 2,];
            %             else numel(size(K))==8
            %             TRANSLATESIEMENSTOISMRMRD=[6, 16, 9, 1, 3, 5, 2,];
            
            %             KO=permute(K,TRANSLATESIEMENSTOISMRMRD);
            
            
            switch(numel(size(K)))
                case 3
                K=permute(K,[1 3 2]);
                KO=reshape(K,[1, 1, 1, size(K,1), size(K,2) ,1, size(K,3)]);
                l={'Kspace siemens 3D ','ok'};
                
                case 4
                r=[size(K)];KN=reshape(K,[1 1 1 1 r([1 2 3])]);
                KO=permute(KN,[1 2 3 5 7 4 6]);
                l={'Kspace siemens 4D ','ok'};
                
                case 5
                r=[size(K)];KN=reshape(K,[1  1 1 r([1 2 3 5])]);
                KO=permute(KN,[1 2 3 4 6 7 5]);
                l={'Kspace siemens 4D ','ok'};
                case 6
                r=[size(K)];
                KN=reshape(K,[1 1 r([1 2 3 5 6])]);
                KO=permute(KN,[7 1 2 3 5 6 4]);
                
                l={'Kspace siemens 6D ','ok'};
                
                
                case 8
                r=size(K);
%                 seleziono solo le componenti che mi servono (sottraggo ad esempio partition)
                KN=reshape(K,[1 r([1 2 3 5 6 8 ])]);
                KO=permute(KN,[7 8 1 2 4 5 3]);
                l={'Kspace siemens 8D ','ok'};
                
                
                
                case 9
                r=size(K);
%                 seleziono solo le componenti che mi servono (sottraggo ad esempio partition)
                KN=reshape(K,r([1 2 3 5 6 8 9]));
                KO=permute(KN,[5 6 7 1 3 4 2]);
                l={'Kspace siemens 9D ','ok'};
                
                otherwise
                    
                l={['Kspace siemens not implemented  ' num2str(numel(size(K))) 'D '],'ko'};
                KO=[];
                
            end
            
            
            
            
            
%              if(numel(size(K)))== 3
%                 K=permute(K,[1 3 2]);
%                 KO=reshape(K,[1, 1, 1, size(K,1), size(K,2) ,1, size(K,3)]);
%                 l={'Kspace siemens 3D ','ok'};
%                 
%             elseif (numel(size(K)))== 4
%                 r=[size(K)];KN=reshape(K,[1 1 1 1 r([1 2 3])]);
%                 KO=permute(KN,[1 2 3 5 7 4 6]);
%                 l={'Kspace siemens 4D ','ok'};
%                 
%             elseif (numel(size(K)))== 5
%                 r=[size(K)];KN=reshape(K,[1  1 1 r([1 2 3 5])]);
%                 KO=permute(KN,[1 2 3 4 6 7 5]);
%                 l={'Kspace siemens 4D ','ok'};
%             elseif (numel(size(K)))== 6
%                 r=[size(K)];KN=reshape(K,[1 1 r([1 2 3 5 6])]);
%                 KO=permute(KN,[7 1 2 3 5 6 4]);
%                 
%                 l={'Kspace siemens 6D ','ok'};
%             elseif (numel(size(K)))== 9
%                 K=permute(K,[1 3 2 4 5 6 7 8 9]);
%                 KO=reshape(K,[size(K,6), 1, size(K,9), size(K,1), size(K,2) ,size(K,5), size(K,3)]);
%                 l={'Kspace siemens 9D ','ok'};
%             else
%                 l={['Kspace siemens not implemented  ' num2str(numel(size(K))) 'D '],'ko'};
%                 KO=[];
%                 
%             end
            
        end
        
    end
    
end
