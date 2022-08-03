function ssvad(sphPath, phnPath, channel)
if (nargin == 2)
    [status, cmdout] = system(sprintf('sph2phn -sph %s -phn %s -dn Y -af 0.95', sphPath, phnPath));
else
    [status, cmdout] = system(sprintf('sph2phn -sph %s -phn %s -ch %s -dn Y -af 0.95', sphPath, phnPath, channel));
end
if (status ~= 0)
    error(cmdout);
end
end