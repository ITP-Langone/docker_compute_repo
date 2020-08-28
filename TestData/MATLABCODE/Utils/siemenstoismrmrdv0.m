function []=siemenstoismrmrdv0(s,n)

[oa,ob]=system(['isRaid -f ' s]);

L=['siemens_to_ismrmrd -f ' s '  -o '];


O=cell(1);
switch str2num(ob(1:2))
    case 1
        O={[L  n ' -z 1']};
       
    case 2
        
        [pt,bn,ext] = fileparts(n);
        
        if isempty(pt)
            pt=pwd;
        end
        O(1)={[L  fullfile(pt,[bn 'noise' ext]) ' -z 1']};
        
        O(2)={[L  fullfile(pt,[bn 'signal' ext]) ' -z 2']};
        
               
       
end


for o=1:numel(O)
    system(O{o});
end
    
