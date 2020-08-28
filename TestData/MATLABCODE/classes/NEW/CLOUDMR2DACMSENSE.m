classdef CLOUDMR2DACMSENSE<CLOUDMRAccelerated
    %this is an initial class derived by the code developped at cbi.
    %sensitivity.
    %http://mriquestions.com/senseasset.html
    %last update 2020 Jan
    %---------------------------------------------------------------------
    %kspace is at the fully sampled size and with zeros on the accelerated
    %position
    
    properties
        
        
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
            this.Autocalibration = js.Autocalibration;
            if(isfield(js,'GFactorMask'))
                this.GFactorMaskID =js.GFactorMask;
            else
                
            end
            
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
        
        
        
        
        
        function snr=getSNR(this)
            %
            %  SNR Analysis Toolbox Version 4.0
            %
            % ----------------------------------
            % Riccardo Lattanzi <riccardo.lattanzi@nyulangone.org>
            % September 13, 2013
            % and Eros Montin <eros.montin@nyulangone.org>
            
            
            
            noisecov=this.getNoiseCovariance();
            coilsens_set=this.getSensitivityMatrix();
            Kcoils=this.getSignalKSpace();
            [nrow, ncol,NC]=size(Kcoils);
            
            
            
            %  [~,~,~, info]=undersamplemSense2D(Kcoils,this.AccelerationF,this.AccelerationP,this.Autocalibration);
            
            
            acc=[this.AccelerationF this.AccelerationP];
            
            
            %shrinkthecoil
            Kcoils=shrinkundersampleaccelerated2D(Kcoils,this.AccelerationF,this.AccelerationP);
            
            [nrowacc, ncolacc,NCacc]=size(Kcoils);
            
            img_matrix=this.get2DKSIFFT(Kcoils);
            
            if (this.AccelerationF>1 && this.AccelerationP>1 )
                if (mod(this.AccelerationF ,2)==0)
                    img_matrix=ifftshift(img_matrix,1);
                end
                if (mod(this.AccelerationP ,2)==0)
                    img_matrix=ifftshift(img_matrix,2);
                end
                
            else
                if (mod(this.AccelerationP ,2)==0)
                    img_matrix=ifftshift(img_matrix,2);
                end
                
            end
            
            
            fullrow=nrow;
            fullcol=ncol;
            
            THETEST=zeros(fullrow,fullcol);
            
            
            for irow = 1:nrowacc
                if (length(acc)>1)
                    freq_set = floor(irow:fullrow/acc(1):(fullrow + 0.5));
                else
                    freq_set = irow;
                end
                for icol = 1:ncolacc
                    if (length(acc)>1)
                        phase_set = floor(icol:fullcol/acc(2):(fullcol+0.5));
                    else
                        phase_set = floor(icol:fullcol/acc:(fullcol+0.5));
                    end
                    s_matrix = squeeze(coilsens_set(freq_set,phase_set,:));
                    
                    
                                
                    I=irow;
                    J=icol;
                    
                    s_matrix = reshape(s_matrix,[numel(freq_set)*numel(phase_set) NC]);
                    s_matrix = s_matrix.';
                    u_matrix = inv((s_matrix')*inv(noisecov)*s_matrix)*(s_matrix')*inv(noisecov);
                    %snr(freq_set,phase_set) = snr(freq_set,phase_set)+reshape(sqrt(2)*(u_matrix)*squeeze(img_matrix(I,J,:))./diag(sqrt((u_matrix)*noisecov*(u_matrix'))),[length(freq_set) length(phase_set)]);
                    ss = reshape(sqrt(2)*(u_matrix)*squeeze(img_matrix(I,J,:))./diag(sqrt((u_matrix)*noisecov*(u_matrix'))),[length(freq_set) length(phase_set)]);
                    %snr(freq_set,phase_set)=nanmean(cat(3,snr(freq_set,phase_set),ss),3);%
                    
                    
                    snr(freq_set,phase_set)=ss;
                    
                  
                    
                    
                end
                
            end
            
            
            %             mesh(THETEST,[0 1]); title(num2str(max(THETEST(:))));
        end
        
        
        
        function snr=getSNRold(this)
            %
            %  SNR Analysis Toolbox Version 4.0
            %
            % ----------------------------------
            % Riccardo Lattanzi <riccardo.lattanzi@nyumc.org>
            % September 13, 2013
            % and Eros Montin <eros.montin@nyulangone.org>
            noisecov=this.getNoiseCovariance();
            coilsens_set=this.getSensitivityMatrix();
            Kcoils=this.getSignalKSpace();
            [nrow, ncol,NC]=size(Kcoils);
            acc=[this.AccelerationF this.AccelerationP];
            img_matrix=this.get2DKSIFFT(Kcoils);
            snr=nan(nrow,ncol);
            
            
            NP=nrow*ncol;
            
            
            
            
            
            for d=1:NP
                theindex=d;
                %pixels can be inside or outside the calibration matrix
                %for pixels outside
                OFFSET(1)=nrow/acc(1);
                OFFSET(2)=ncol/acc(2);
                
                [I,J] = ind2sub([nrow ncol],theindex);
                freq_set=union([I:OFFSET(1):nrow],[I:-OFFSET(1):1]);
                
                phase_set=union([J:OFFSET(2):ncol],[J:-OFFSET(2):1]);
                %got the pixels of the sensitivity amtrix
                s_matrix = squeeze(coilsens_set(freq_set,phase_set,:));
                
                try
                    
                    s_matrix = reshape(s_matrix,[numel(freq_set)*numel(phase_set) NC]);
                    s_matrix = s_matrix.';
                    u_matrix = inv((s_matrix')*inv(noisecov)*s_matrix)*(s_matrix')*inv(noisecov);
                    %snr(freq_set,phase_set) = snr(freq_set,phase_set)+reshape(sqrt(2)*(u_matrix)*squeeze(img_matrix(I,J,:))./diag(sqrt((u_matrix)*noisecov*(u_matrix'))),[length(freq_set) length(phase_set)]);
                    ss = reshape(sqrt(2)*(u_matrix)*squeeze(img_matrix(I,J,:))./diag(sqrt((u_matrix)*noisecov*(u_matrix'))),[length(freq_set) length(phase_set)]);
                    snr(freq_set,phase_set)=nanmean(cat(3,snr(freq_set,phase_set),ss),3);
                catch
                    %                    s_matrix = reshape(s_matrix,[prod(acc) NC]);
                    %these are the pixels in the caliobration
                    display([num2str(I) ' ' num2str(J)]);
                end
            end
            
            
            
            
        end
        
        
        
        
        
        
        
        function [o]=getImage(this)
            sens=this.getSensitivityMatrix();
            sens=this.bartMy2DKSpace(sens);
            K=this.bartMy2DKSpace(this.getSignalKSpace());
            o = bart('pics -r0.', K, sens);
        end
        
        
        function G=getGFactor(this)
            noisecov=this.getNoiseCovariance();
            coilsens_set=this.getSensitivityMatrix();
            [nrow, ncol,NC]=size(coilsens_set);
            acc=[this.AccelerationF this.AccelerationP];
            G=zeros(nrow,ncol);
            
            
            NP=nrow*ncol;
            
            for d=1:NP
                theindex=d;
                OFFSET(1)=nrow/acc(1);
                OFFSET(2)=ncol/acc(2);
                
                [I,J] = ind2sub([nrow ncol],theindex);
                freq_set=union([I:OFFSET(1):nrow],[I:-OFFSET(1):1]);
                
                phase_set=union([J:OFFSET(2):nrow],[J:-OFFSET(2):1]);
                s_matrix = squeeze(coilsens_set(freq_set,phase_set,:));
                
                try
                    
                    s_matrix = reshape(s_matrix,[numel(freq_set)*numel(phase_set) NC]);
                    s_matrix = s_matrix.';
                    u_matrix = inv((s_matrix')*inv(noisecov)*s_matrix)*(s_matrix')*inv(noisecov);
                    ff = reshape( sqrt(prod(acc)*diag(inv((s_matrix')*inv(noisecov)*s_matrix)).*diag((s_matrix')*inv(noisecov)*s_matrix)), [length(freq_set) length(phase_set)]);
                    
                    G(freq_set,phase_set)=nanmean(cat(3,G(freq_set,phase_set),ff),3);
                catch
                    
                    
                    
                end
            end
            
        end
        
    end
end


