function []=colormapcreator(L,name)




fprintf(1,['var ' name ' =[']);
for t=1:size(L,1)
    fprintf(1, ['[' num2str(t) ', [' num2str(L(t,1)) ',' num2str(L(t,2)) ', ' num2str(L(t,3)) ']],']);
end

L(end)=[];
fprintf(1,'];');

end