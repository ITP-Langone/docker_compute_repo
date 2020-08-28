function [M]=createGFactorMaskFromJson(x)
o=webread(x);

[nx,ny]=ndgrid(1:o.w,1:o.h);

mo=TriScatteredInterp([o.vx o.vy]+1,o.v,'nearest');
M=mo(nx,ny);
% imagesc(M);

end