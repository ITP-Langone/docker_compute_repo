classdef CLOUDMROutput<handle
    %main class of output, the constructor is ovewritten by
    %-----------------------------------------------------------------------------------
    %the class constructor v20200326
    %getJsonResultFromJsonFile get structured data from jsonfilename
    %getImagsesFromJsonResultFile('phantom.json'); %get results images from
    %jsonfilename
    %O.getImagesFromResuls get images from struct data
    %-----------------------------------------------------------------------------------
    %the class constructor v20200325
    %-----------------------------------------------------------------------------------
    
    properties
        Exporter % a cell array of name and alues to be exported
        LOG
        TEX
        mat
        Type
        subType
        OUTPUTLOGFILENAME
        OUTPUTFILENAME
    end
    
    
    
    
    methods
        function this = CLOUDMROutput()
            try
                TurnOffWarnings();
                
            catch
                
            end
            this.TEX='\documentclass[a4paper]{article}\usepackage{amsmath}\begin{document}';
            
            
            
            
        end
        
        
        function setOutputLogFileName(this,L)
            this.OUTPUTLOGFILENAME=L;
        end
        
        function o=getOutputLogFileName(this)
            o=this.OUTPUTLOGFILENAME;
        end
        
        
        function setOutputFileName(this,L)
            this.OUTPUTFILENAME=L;
        end
        
        function o=getOutputFileName(this)
            o=this.OUTPUTFILENAME;
        end
        
        
        function setLOG(this,L)
            this.LOG=L;
        end
        
        function o=getLOG(this,L)
            o=this.LOG;
        end
        
        
        
        
        function appendLOG(this,L)
            this.setLOG(cat(2,this.getLOG,L));
        end
        
        function logIT(this,W,t)
            
            j.time=datestr(clock);
            j.text=W;
            j.type=t;
            this.LOG=[this.LOG j];
            
        end
        
        
        
        function addToExporter(this,type,name,value)
            this.Exporter=[this.Exporter;[{type},{name},{double(value)}]];
        end
        
        function exportResults(this,fn)
            
            O.version='20180831';
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
            
            
            
            
            for t=1:size(this.Exporter,1)
                if(strcmp(this.Exporter{t,1},'image2D'))
                    im.slice=this.image2DtoJson(this.Exporter{t,3});
                    im.imageName=this.Exporter{t,2};
                    O.images(t)=im;
                    clear im;
                    
                end
                
                
            end
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
        
        
        
        
        
        
        function exportLOG(this,fn)
            if(nargin>1)
                myjsonWrite(jsonencode(this.LOG),fn);
            else
                try
                    myjsonWrite(jsonencode(this.LOG),this.getOutputLogFileName());
                catch
                    display('error');
                end
                
            end
        end
        
        function whatHappened(this)
            for t=1:numel(this.LOG)
                display(this.LOG(t));
            end
        end
        
        
        
        function errorMessage(this)
            this.logIT('ERROR','error');
        end
        
        function outputError(this,fn)
            this.errorMessage();
            this.exportLOG(fn);
        end
        
        function exportResultsLatex(this,fn)
            
            this.TEX=[this.TEX '\end{document}'];
            system(['pdflatex ' fn]);
        end
        
        
        
        
        function add2DImagetoExport(this,im,name)
            this.addToExporter('image2D',name,im);
        end
    end
    
    methods (Static)
        
        function Oout=image2DtoJson(im)
            for sl=1:size(im,3)
                o=im(:,:,sl)';
                O.w=size(o,2);
                O.h=size(o,1);
                O.type= 'double complex';
                O.Vr=real(reshape(o,1,[]));
                O.Vi=imag(reshape(o,1,[]));
                Oout(sl)=O;
            end
        end
        
        function o=get2DKSIFFT(k)
            % reconstruct individual coils' images and apply FFT scale factor
            % iFFT scales data by 1/sqrt(N), so I need to scale back, as the noise covariance
            % matrix is calculated in k-space (not Fourier transformed)
            
            o=MRifft(k,[1,2])*sqrt(size(k,1)*size(k,2));
        end
        
        
        function o=bartMy2DKSpace(K,cartesianFLAG)
            
            if nargin>1
                if(noncartesianFLAG)
                    display('not yet implemented')
                else
                    o(:,:,1,:)=K;
                end
            else
                if nargin>0
                    o(:,:,1,:)=K;
                else
                    o=[];
                    display('nothing to display');
                    
                end
            end
            
        end
        
        
        function o=debartMy2DKSpace(K,cartesianFLAG)
            o=[];
            if nargin>1
                if(noncartesianFLAG)
                    display('not yet implemented')
                else
                    o=squeeze(K);
                end
            else
                if nargin>0
                    o=squeeze(K);
                else
                    
                    display('nothing to display');
                    
                end
            end
            o=double(o);
        end
        
        function im=getSOSImage(k)
            
            im= CLOUDMROutput.get2DKSIFFT(k);
            %im = sqrt(sum(abs(im).^2,3));
            im=sqrt(sum(im.*conj(im),3));
            %             im = sqrt(sum(im.^2,3));
        end
        
        
        %                 function im=getSOSImage(k)
        %
        %             im= CLOUDMROutput.get2DKSIFFT(k);
        %             im = sqrt(sum(im.^2,3));
        %             %             im = sqrt(sum(im.^2,3));
        %         end
        
        function o=kron512(m)
            n=floor(512/size(m,1));
            o= kron(m,ones(n));
            
        end
        
        function o=rescale01(bla)
            MI=min(bla(:));
            MA=max(bla(:));
            o= (bla(:) - MI)./ ( MA - MI );
        end
        
        
        
        function o=mimic2DSENSEfromFullysampled(m,accelerationF,accelerationP)
            %what are we doing if mod!=0?
            %round? ceil? floor?
            
            SF=size(m,1);
            SP=size(m,2);
            
            
            if((mod(SF/accelerationF,1)==0) && (mod(SP/accelerationP,1)==0))
                
                o=m(1:accelerationF:end,1:accelerationP:end,:);
                
                
                
                
                
            else
                
                
                o=[];
                
            end
            
            
        end
        
        function [O]=getJsonResultFromJsonFile(file)
            %from sjsonfilename i got the struct of data
            
            
            O=readanddecodejson(file);
            
        end
        
        
        
        function [O]=getImagsesFromJsonResultFile(file)
            %from the json results file get the entire image
            %set in a struct variable
            
            data=readanddecodejson(file);
            O=CLOUDMROutput.getImagesFromResuls(data);
        end
        
        function [O] =getImagesFromResuls(data)
            %from the struct derived by the json results file got the entire image
            %set
            
            for imnumber=1:numel(data.images)
                h=data.images(imnumber).slice.h;
                w= data.images(imnumber).slice.w;
                NSL=numel(data.images(imnumber).slice);
                clear image_;
                %we switch i know!:)
                image_=NaN(w,h,NSL);
                O(imnumber).ImageName=data.images(imnumber).imageName;
                for slnumber=1:NSL
                    a=data.images(imnumber).slice(slnumber).Vr(:)+data.images(imnumber).slice(slnumber).Vi(:)*1i;
%                     image_tmp=NaN(h,w);
%                     image_tmp(:)=a;
                    image_(:,:,slnumber)=reshape(a,h,w).';
                end
                O(imnumber).image=image_;
                
                
            end
        end
        
        
        
        
        function write2DCartesianKspacedatainISMRMRDv1(K,filename)
            % It is very slow to append one acquisition at a time, so we're going
            % to append a block of acquisitions at a time.
            % In this case, we'll do it one repetition at a time to show off this
            % feature.  Each block has nYsamp aquisitions
            
            
            
            
            
            %
            % f='meas_MID00024_FID188178_Multislice.dat';
            %
            % F=CLOUDMRRD(f);
            
            
            % K=F.getNoiseKSpace();
            %
            %
            %
            % size(K)
            % 1     1     1    96    96     5    16
            %   O={'1: Average',
            %       '2: contrast',
            %       '3: repetition',
            %       '4: Frequency Encode',
            %       '5: Phase Encode',
            %       '6: Slice',
            %       '7: Coils'};
            
            
            
            
            
            % filename ='test.H5';
            dset = ismrmrd.Dataset(filename);
            
            
            nX=size(K,4);
            nCoils=size(K,7);
            nYsamp=prod(size(K))/(nX*nCoils);
            nAvg=size(K,1);
            nCnt=size(K,2);
            nRep=size(K,3);
            nPh=size(K,5);
            nSl=size(K,6);
            
            %nYsamp is number of actually
            acqblock = ismrmrd.Acquisition(nYsamp);
            
            
            % Set the header elements that don't change
            acqblock.head.version(:) = 1;
            acqblock.head.number_of_samples(:) = nX;
            acqblock.head.center_sample(:) = floor(nX/2);
            acqblock.head.active_channels(:) = nCoils;
            acqblock.head.available_channels(:) =nCoils;
            acqblock.head.read_dir  = repmat([1 0 0]',[1 nYsamp]);
            acqblock.head.phase_dir = repmat([0 1 0]',[1 nYsamp]);
            acqblock.head.slice_dir = repmat([0 0 1]',[1 nYsamp]);
            
            
            
            
            
            counter=0;
            
            for avg=1:nAvg
                
                
                
                
                for cnt=1:nCnt
                    for rep = 1:nRep
                        
                        for sl = 1:nSl
                            for p = 1:nPh
                                counter=counter+1;
                                
                                if (p==1)
                                    acqblock.head.flagClearAll(counter);
                                    acqblock.head.flagSet('ACQ_FIRST_IN_ENCODE_STEP1',counter);
                                    
                                    if avg == 1
                                        acqblock.head.flagSet('ACQ_FIRST_IN_AVERAGE',counter);
                                    end
                                    if rep == 1
                                        acqblock.head.flagSet('ACQ_FIRST_IN_REPETITION',counter);
                                    end
                                    if cnt == 1
                                        acqblock.head.flagSet('ACQ_FIRST_IN_CONTRAST',counter);
                                    end
                                    if sl == 1
                                        acqblock.head.flagSet('ACQ_FIRST_IN_SLICE',counter);
                                    end
                                    
                                    
                                    
                                end
                                
                                % Set the header elements that change from acquisition to the next
                                % c-style counting
                                acqblock.head.scan_counter(counter) = counter;
                                % Note next entry is k-space encoded line number (not acqno which
                                % is just the sequential acquisition number)
                                acqblock.head.idx.kspace_encode_step_1(counter) = p-1;
                                acqblock.head.idx.repetition(counter) = rep-1;
                                acqblock.head.idx.average(counter) = avg-1;
                                
                                acqblock.head.idx.slice(counter)=sl-1;
                                acqblock.head.idx.contrast(counter)=cnt-1;
                                acqblock.head.idx.kspace_encode_step_2(counter)=0;
                                acqblock.head.idx.segment(counter)=0;
                                acqblock.head.idx.set(counter)=0;
                                
                                % fill the data
                                acqblock.data{counter} = squeeze(K(avg,cnt,rep,:,p,sl,:));
                                % Append the acquisition block
                                
                                
                                if counter==nPh
                                    
                                    
                                    acqblock.head.flagSet('ACQ_LAST_IN_ENCODE_STEP1',counter);
                                    
                                    if avg == nAvg
                                        acqblock.head.flagSet('ACQ_LAST_IN_AVERAGE',counter);
                                    end
                                    if rep == nRep
                                        acqblock.head.flagSet('ACQ_LAST_IN_REPETITION',counter);
                                    end
                                    if cnt == nCnt
                                        acqblock.head.flagSet('ACQ_LAST_IN_CONTRAST',counter);
                                    end
                                    
                                    if sl == nSl
                                        acqblock.head.flagSet('ACQ_LAST_IN_SLICE',counter);
                                    end
                                    
                                    
                                    
                                    
                                end
                                
                                
                                
                                
                            end
                            
                            if sl ==nSl
                                acqblock.head.flagSet('ACQ_LAST_IN_SLICE',counter);
                            end
                        end
                    end
                end
            end
            acqblock.head.flagSet('ACQ_LAST_IN_MEASUREMENT',counter);
            
            dset.appendAcquisition(acqblock);
            
            
            %get the resolution ffrom somewhere
            
            r=[1 1 1];
            
            %%%%%%%%%%%%%%%%%%%%%%%%
            %% Fill the xml header %
            %%%%%%%%%%%%%%%%%%%%%%%%
            % We create a matlab struct and then serialize it to xml.
            % Look at the xml schema to see what the field names should be
            
            header = [];
            
            % Experimental Conditions (Required)
            header.experimentalConditions.H1resonanceFrequency_Hz = 128000000; % 3T
            
            % Acquisition System Information (Optional)
            header.acquisitionSystemInformation.systemVendor = 'CLOUDMR www.cloudmrhub.com';
            header.acquisitionSystemInformation.systemModel = 'CM scanner v01';
            header.acquisitionSystemInformation.receiverChannels = nCoils;
            header.acquisitionSystemInformation.systemFieldStrength_T=2.893620;
            header.acquisitionSystemInformation.relativeReceiverNoiseBandwidth=0793;
            
            % The Encoding (Required)
            header.encoding.trajectory = 'cartesian';
            header.encoding.encodedSpace.fieldOfView_mm.x = nX*r(1);
            header.encoding.encodedSpace.fieldOfView_mm.y = nPh*r(2);
            header.encoding.encodedSpace.fieldOfView_mm.z = nSl*r(3);
            header.encoding.encodedSpace.matrixSize.x = nX;
            header.encoding.encodedSpace.matrixSize.y = nPh;
            header.encoding.encodedSpace.matrixSize.z = 1;
            % Recon Space
            % (in this case same as encoding space)
            header.encoding.reconSpace = header.encoding.encodedSpace;
            % Encoding Limits
            header.encoding.encodingLimits.kspace_encoding_step_0.minimum = 0;
            header.encoding.encodingLimits.kspace_encoding_step_0.maximum = nX-1;
            header.encoding.encodingLimits.kspace_encoding_step_0.center = floor(nX/2);
            header.encoding.encodingLimits.kspace_encoding_step_1.minimum = 0;
            header.encoding.encodingLimits.kspace_encoding_step_1.maximum = nPh-1;
            header.encoding.encodingLimits.kspace_encoding_step_1.center = floor(nPh/2);
            
            header.encoding.encodingLimits.kspace_encoding_step_2.minimum = 0;
            header.encoding.encodingLimits.kspace_encoding_step_2.maximum = 0;
            header.encoding.encodingLimits.kspace_encoding_step_2.center = 0;
            
            header.encoding.encodingLimits.repetition.minimum = 0;
            header.encoding.encodingLimits.repetition.maximum = nRep-1;
            header.encoding.encodingLimits.repetition.center = 0;
            
            header.encoding.encodingLimits.average.minimum = 0;
            header.encoding.encodingLimits.average.maximum = nAvg-1;
            header.encoding.encodingLimits.average.center = 0;
            
            
            header.encoding.encodingLimits.phase.minimum = 0;
            header.encoding.encodingLimits.phase.maximum = nPh-1;
            header.encoding.encodingLimits.phase.center = 0;
            
            
            header.encoding.encodingLimits.contrast.minimum = 0;
            header.encoding.encodingLimits.contrast.maximum = nCnt-1;
            header.encoding.encodingLimits.contrast.center = 0;
            
            header.encoding.encodingLimits.slice.minimum = 0;
            header.encoding.encodingLimits.slice.maximum = nSl-1;
            header.encoding.encodingLimits.slice.center = 0;
            
            header.encoding.parallelImaging.accelerationFactor.kspace_encoding_step_1 = 1 ;
            header.encoding.parallelImaging.accelerationFactor.kspace_encoding_step_2 = 1 ;
            % header.encoding.parallelImaging.calibrationMode = 'embedded' ;
            
            % Commented code below appears not necessary - saw this parameter after converting
            % a scanner file using siemens_to_ismrmrd
            % header.userParameters.userParameterLong.name = 'EmbeddedRefLinesE1' ;
            % header.userParameters.userParameterLong.value = ACShw *2  ;
            
            %% Serialize and write to the data set
            xmlstring = ismrmrd.xml.serialize(header);
            dset.writexml(xmlstring);
            
            %% Write the dataset
            dset.close();
            
        end
        
        
        
    end
end

