function [SNR] = DI(im1,im2,roi,index)

if nargin<4
r=find(roi);
else
    r=index;
end
vim1=im1(r);
vim2=im2(r);

SNR=nanmean(vim1+vim2)./(sqrt(2)*nanstd(vim1-vim2));

end

