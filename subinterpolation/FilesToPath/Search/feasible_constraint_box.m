function [x]=feasible_constraint_box(x,xi,ind)
global n acon Ain bin r bnd1 bnd2
% the feasibel constraint projection for bound constraint problem
for jj=1:2*n
d=-Ain(jj,:)*x+bin(jj);
e=mindis(x,xi(:,acon{jj}));
if d/e<1/r
    acon{jj}=[acon{jj} ind];
    if jj<n+1
     x(jj)=bnd2(jj);
 else 
     x(jj-n)=bnd1(jj-n);
 end
end
end