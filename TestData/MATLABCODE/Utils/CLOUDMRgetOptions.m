function o=CLOUDMRgetOptions(type,options)

if nargin>0
    switch(lower(type))
        case 'rssbart'
            o.FlipAngleMap="no";
            o.Type='RSSBART';
        case 'b1espirit'
            o.FlipAngleMap="no";
            o.NoiseFileType='noiseFile';
            o.Type='B1';
            o.SensitivityCalculationMethod='espirit';
            o.SourceCoilSensitivityMap='self';
            o.SaveCoils=false;
            o.NBW=1;
            o.SourceCoilSensitivityMapSmooth=false;
        case 'b1bartespirit'
            o.FlipAngleMap="no";
            o.NoiseFileType='noiseFile';
            o.Type='B1BART';
            o.SensitivityCalculationMethod='espirit';
            o.SourceCoilSensitivityMap='self';
            o.SaveCoils=false;
            o.NBW=1;
            o.SourceCoilSensitivityMapSmooth=false;
            
        case 'b1bc'
            o.FlipAngleMap="no";
            o.NoiseFileType='noiseFile';
            o.Type='B1';
            o.SensitivityCalculationMethod='BodyCoil';
            o.SourceCoilSensitivityMap='self';
            o.SaveCoils=false;
            o.NBW=1;
            o.bc='filenameBC';
            o.SourceCoilSensitivityMapSmooth=false;
        case {'b1sense','b1simplesense'}
            o.FlipAngleMap="no";
            o.NoiseFileType='noiseFile';
            o.Type='B1';
            o.SensitivityCalculationMethod='simplesense';
            o.SourceCoilSensitivityMap='self';
            o.SaveCoils=false;
            o.NBW=1;
            o.SourceCoilSensitivityMapSmooth=false;
        case 'rss'
            o.Type='RSS';
            o.UseCovarianceMatrix=true; %normal
            o.FlipAngleMap="no";
            o.NBW=1;
            o.NR=0;
            o.NoiseFileType='noiseFile';
        case 'espirits'
            o.FlipAngleMap="no";
            o.NoiseFileType='noiseFile';
            o.Type='espirit';
            o.SensitivityCalculationMethod='espirit';
            o.SourceCoilSensitivityMap='self';
            o.SaveCoils=false;
            o.NBW=1;
            o.SourceCoilSensitivityMapSmooth=false;
            o.AccelerationF=1;
            o.AccelerationP=2;
            o.Autocalibration=24;
            
        case 'msensebartsense'
            o.FlipAngleMap="no";
            o.NoiseFileType='noiseFile';
            o.Type='msense';
            o.SensitivityCalculationMethod='bartsense';
            o.SourceCoilSensitivityMap='self';
            o.SaveCoils=false;
            o.NBW=1;
            o.SourceCoilSensitivityMapSmooth=false;
            o.AccelerationF=1;
            o.AccelerationP=2;
            o.Autocalibration=24;
        case 'msensesepirit'
            o.FlipAngleMap="no";
            o.NoiseFileType='noiseFile';
            o.Type='msense';
            o.SensitivityCalculationMethod='espirit';
            o.SourceCoilSensitivityMap='self';
            o.SaveCoils=false;
            o.NBW=1;
            o.SourceCoilSensitivityMapSmooth=false;
            o.AccelerationF=1;
            o.AccelerationP=2;
            o.Autocalibration=24;
        case 'msensesimplesense'
            o.FlipAngleMap="no";
            o.NoiseFileType='noiseFile';
            o.Type='msense';
            o.SensitivityCalculationMethod='simplesense';
            o.SourceCoilSensitivityMap='self';
            o.SaveCoils=false;
            o.NBW=1;
            o.SourceCoilSensitivityMapSmooth=false;
            o.AccelerationF=1;
            o.AccelerationP=2;
            o.Autocalibration=24;
        case 'msenseadaptive'
            o.FlipAngleMap="no";
            o.NoiseFileType='noiseFile';
            o.Type='msense';
            o.SensitivityCalculationMethod='simplesense';
            o.SourceCoilSensitivityMap='self';
            o.SaveCoils=false;
            o.NBW=1;
            o.SourceCoilSensitivityMapSmooth=false;
            o.AccelerationF=1;
            o.AccelerationP=2;
            o.Autocalibration=24;
            
    end
    
    
    ON=fieldnames(o);
    c=0;
    
    
    if exist('options','var')
        if(isstruct(options))
            FN=fieldnames(options);
            
            for t=1:numel(FN)
                %                  if(isfifunction o=CLOUDMRgetOptions(type,options)

if nargin>0
    switch(lower(type))
        case 'rssbart'
            o.FlipAngleMap="no";
            o.Type='RSSBART';
        case 'b1espirit'
            o.FlipAngleMap="no";
            o.NoiseFileType='noiseFile';
            o.Type='B1';
            o.SensitivityCalculationMethod='espirit';
            o.SourceCoilSensitivityMap='self';
            o.SaveCoils=false;
            o.NBW=1;
            o.SourceCoilSensitivityMapSmooth=false;
        case 'b1bartespirit'
            o.FlipAngleMap="no";
            o.NoiseFileType='noiseFile';
            o.Type='B1BART';
            o.SensitivityCalculationMethod='espirit';
            o.SourceCoilSensitivityMap='self';
            o.SaveCoils=false;
            o.NBW=1;
            o.SourceCoilSensitivityMapSmooth=false;
            
        case 'b1bc'
            o.FlipAngleMap="no";
            o.NoiseFileType='noiseFile';
            o.Type='B1';
            o.SensitivityCalculationMethod='BodyCoil';
            o.SourceCoilSensitivityMap='self';
            o.SaveCoils=false;
            o.NBW=1;
            o.bc='filenameBC';
            o.SourceCoilSensitivityMapSmooth=false;
        case {'b1sense','b1simplesense'}
            o.FlipAngleMap="no";
            o.NoiseFileType='noiseFile';
            o.Type='B1';
            o.SensitivityCalculationMethod='simplesense';
            o.SourceCoilSensitivityMap='self';
            o.SaveCoils=false;
            o.NBW=1;
            o.SourceCoilSensitivityMapSmooth=false;
        case 'rss'
            o.Type='RSS';
            o.UseCovarianceMatrix=true; %normal
            o.FlipAngleMap="no";
            o.NBW=1;
            o.NR=0;
            o.NoiseFileType='noiseFile';
        case 'espirits'
            o.FlipAngleMap="no";
            o.NoiseFileType='noiseFile';
            o.Type='espirit';
            o.SensitivityCalculationMethod='espirit';
            o.SourceCoilSensitivityMap='self';
            o.SaveCoils=false;
            o.NBW=1;
            o.SourceCoilSensitivityMapSmooth=false;
            o.AccelerationF=1;
            o.AccelerationP=2;
            o.Autocalibration=24;
            
        case 'msensebartsense'
            o.FlipAngleMap="no";
            o.NoiseFileType='noiseFile';
            o.Type='msense';
            o.SensitivityCalculationMethod='bartsense';
            o.SourceCoilSensitivityMap='self';
            o.SaveCoils=false;
            o.NBW=1;
            o.SourceCoilSensitivityMapSmooth=false;
            o.AccelerationF=1;
            o.AccelerationP=2;
            o.Autocalibration=24;
        case 'msensesepirit'
            o.FlipAngleMap="no";
            o.NoiseFileType='noiseFile';
            o.Type='msense';
            o.SensitivityCalculationMethod='espirit';
            o.SourceCoilSensitivityMap='self';
            o.SaveCoils=false;
            o.NBW=1;
            o.SourceCoilSensitivityMapSmooth=false;
            o.AccelerationF=1;
            o.AccelerationP=2;
            o.Autocalibration=24;
        case 'msensesimplesense'
            o.FlipAngleMap="no";
            o.NoiseFileType='noiseFile';
            o.Type='msense';
            o.SensitivityCalculationMethod='simplesense';
            o.SourceCoilSensitivityMap='self';
            o.SaveCoils=false;
            o.NBW=1;
            o.SourceCoilSensitivityMapSmooth=false;
            o.AccelerationF=1;
            o.AccelerationP=2;
            o.Autocalibration=24;
        case 'msenseadaptive'
            o.FlipAngleMap="no";
            o.NoiseFileType='noiseFile';
            o.Type='msense';
            o.SensitivityCalculationMethod='simplesense';
            o.SourceCoilSensitivityMap='self';
            o.SaveCoils=false;
            o.NBW=1;
            o.SourceCoilSensitivityMapSmooth=false;
            o.AccelerationF=1;
            o.AccelerationP=2;
            o.Autocalibration=24;
            
    end
    
    
    ON=fieldnames(o);
    c=0;
    
    
    if exist('options','var')
        if(isstruct(options))
            FN=fieldnames(options);
            
            for t=1:numel(FN)
                %                  if(isfield(o,FN{t})
                %                      if()
                %                      c=c+1;
                %                  else
                %                      c=c+1;
                %                  end
                c=c+1;
                eval(['o.' FN{t} '=options.' FN{t} ';']);
            end
            display([num2str(c) ' field overloaded over ' num2str(numel( fieldnames(o))) ' (originally ' num2str(numel(ON)) ')']);
        end
    end
    
else
    o=[];
    METHODS={'b1espirit','rssbart','msensebartsense','msenseespirits','msensesimplesense','msenseadaptive','rss','b1simplesense','b1bc'};
    fprintf(1,'available methods ')
    for m=1:numel(METHODS)
        fprintf(1,[METHODS{m} ', ']);
    end
    fprintf(1,'\b\b  \neros.montin@gmail.com\n');
    
    
end
endeld(o,FN{t})
                %                      if()
                %                      c=c+1;
                %                  else
                %                      c=c+1;
                %                  end
                c=c+1;
                eval(['o.' FN{t} '=options.' FN{t} ';']);
            end
            display([num2str(c) ' field overloaded over ' num2str(numel( fieldnames(o))) ' (originally ' num2str(numel(ON)) ')']);
        end
    end
    
else
    o=[];
    METHODS={'b1espirit','rssbart','msensebartsense','msenseespirits','msensesimplesense','msenseadaptive','rss','b1simplesense','b1bc'};
    fprintf(1,'available methods ')
    for m=1:numel(METHODS)
        fprintf(1,[METHODS{m} ', ']);
    end
    fprintf(1,'\b\b  \neros.montin@gmail.com\n');
    
    
end
end