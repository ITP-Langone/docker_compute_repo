function [L,o]=CLOUDMRgetclassfromOptions(o)

if nargin>0
    %    switch lower(m)
    switch lower(o.Type)
        case 'rss'
            L=CLOUDMR2DACMRSS();
        case {'rssbart','rssbast'} %misspelled once.. fixed now:)
            L=CLOUDMR2DACMRSSBART();
        case 'sense'
            L=CLOUDMR2DACMSENSE();
            
        case 'b1'
            L=CLOUDMR2DACMB1();
        case 'b1bart'
            L=CLOUDMR2DACMB1BART();
        case 'msense'
            L=CLOUDMR2DACMmSENSE();
        case 'espirit'
            L=CLOUDMR2DACMEspirit();
            
        otherwise
            L=CLOUDMR2DACM();
            
    end
    
    
else
    o=[];
    METHODS={'rss','rssbart','sense','b1','b1bart','msense','espirit'};
    fprintf(1,'available methods ')
    for m=1:numel(METHODS)
        fprintf(1,[METHODS{m} ', ']);
    end
    fprintf(1,'\b\b  \neros.montin@gmail.com\n');
    
    
end