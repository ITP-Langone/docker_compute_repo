function o=transformRawDataOV2NV(n)
            %x,y,channel
            o=reshape(n,[size(n,1), size(n,2), 1 ,size(n,3)]);
        end
