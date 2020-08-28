function o=setBincall(bn)
%in: cellarray of bin names linux,windows, mac ordered;
%output string with the correct bin name
if isunix
    o=bn{1};
elseif ispc
        o=bn{2};
elseif ismac
        o=bn{3};
end