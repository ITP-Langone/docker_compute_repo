function O=maskb1IFFT(signalrawdata)

x= round(size(signalrawdata,1)/2);
y= round(size(signalrawdata,2)/2);


s= signalrawdata;
for t=1:size(s,3)

    
    %get the coil sens
    IM=squeeze(s(:,:,t));
    
    OIM=zeros(size(IM));
OIM(x:x+1,y:y+1)=IM(x:x+1,y:y+1);
    

IOIM=abs(MRifft(OIM,[1 2]));
    
X(t,:,:)=(IOIM/max(IOIM(:)))/(size(s,3));

% figure; imagesc(squeeze(X(t,:,:)));

end

            nc=size(s,3);
             b1map = MRifft(signalrawdata,[1,2]);
             ref_img = sqrt(sum(abs(b1map).^2,3));
             b1map = b1map./repmat(ref_img,[1 1 nc]);
                       
             
             [~,b]=hist(ref_img(:),1000);
             
             m = medfilt2(ref_img,[2 2]) > mean([ mean(reshape(ref_img(1:2,1:2),[],1)); mean(reshape(ref_img(end-1:end,1:2),[],1));mean(reshape(ref_img(end-1:end,end-1:end),[],1));mean(reshape(ref_img(1:2,end-1:end),[],1));   b(40)]); % THIS IS IMPORTANT AND WE SHOULD FIND A WAY TO GENERALIZE IT (IT NEEDS TO MASK THE OBJECT FROM THE BACKGROUND)
%              figure; imagesc(m);title('tit');
             
E=(squeeze(sum(X,1))*0.95)+(m*0.1);



A=regionprops(E>0.3,'all');

[~,nn]=max([A.Area]);
L=zeros(size(ref_img));L(A(nn).PixelIdxList)=1;

O=imfill(L,'holes');
%imagesc(squeeze(mean(O,1))); colorbar;
%figure;
%imagesc(reconIT(s));

end