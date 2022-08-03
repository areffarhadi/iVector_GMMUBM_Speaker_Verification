function NIST2004=my_LINUX(sphpath, channel)
NIST2004={};
for i=1:67
    sphfile=sphpath{i,1};
    channeli=channel(i,1);
if (nargin == 1)
    [s] = (sprintf('./sph2phn -sph %s.sph -phn %s.phn -dn Y -af 0.95', sphfile, sphfile));
else
    [s] = (sprintf('./sph2phn -sph %s.sph -phn %s.phn -ch A -dn Y -af 0.95', sphfile, sphfile));
end
NIST2004{i,1}=s;
end
end