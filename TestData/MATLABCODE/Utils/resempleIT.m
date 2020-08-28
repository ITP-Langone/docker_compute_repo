function im=resempleIT(im,old,new)
%im=resempleIT(im,old,new) im what tou want to resample, old a2d image each
%rows has the minimum, the limit and numebr of pixels of the grid


if (numel(size(old))== 2)
        [Nx Ny]=ndgrid(linspace(old(1,1),old(1,2),old(1,3)),linspace(old(2,1),old(2,2),old(2,3)));
        Xo=[Nx(:) Ny(:)];
        clear N*;
       
end

% m=scatteredInterpolant(Xo,im(:));

m=TriScatteredInterp(Xo,im(:));


if (numel(size(old))== 2)
        
        [Nx Ny]=ndgrid(linspace(new(1,1),new(1,2),new(1,3)),linspace(new(2,1),new(2,2),new(2,3)));
            
        im=m(Nx,Ny);
        
end



end

