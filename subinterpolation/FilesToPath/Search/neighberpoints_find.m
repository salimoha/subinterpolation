function [xie ,yie ,inde,tri_ind,tri,xm,NoSearch] = neighberpoints_find(xiT,yiT,k5)
global n y00
tri=delaunayn(xiT.');
inde=[];
tri_ind=[];
[b,ind]=min(yiT); xmin=xiT(:,ind);
for ii=1:size(tri,1)
if (ismember(ind,tri(ii,:)) & min(tri(ii,:))>n+1)
    inde=union(inde,tri(ii,:));
    tri_ind=[tri_ind ii];
end
end
if max(yiT(inde))>min(yiT)+k5*(min(yiT)-y00)
    [b,ind]=max(yiT(inde));
    xm=(xmin+xiT(:,inde(ind)))/2;
    NoSearch=1;
else
    NoSearch=0;
    xm=xmin;
end
xie=xiT(:,inde);
yie=yiT(inde);
end


