function  Q=DBNFea(ss)
% AREF DBN feature extraction from MFCC. dbn config: 195 input 39 outpot
 load('dbn.mat')
  [~,B]=size(ss);
    Y=floor(B/5);    
    Q=zeros(195,Y);
p=1;
q=5;
for j=1:Y
     t=1;
    v=39;
    for i=p:q
        Q(t:v,j)=ss(:,i);
        t=t+39;
        v=v+39;
    end
    p=p+5;
    q=q+5;
end

Q=Q';
Q=dbn.getFeature(Q);
Q=Q';
end