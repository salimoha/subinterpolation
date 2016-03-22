function [x1]=new_add_trust_region(x,xiT,lb,ub,param)
% find the trust region point adding strategy
global n 
if param
[y,ind_min,x1]=mindis(x,xiT(:,n+2:end));
else
[y,ind_min,x1]=mindis(x,xiT);
end

% find active and inctive coordianates at x
indl=1:n; indl=indl(abs(x-lb)<1e-3);
indu=1:n; indu=indu(abs(x-ub)<1e-3);
ind_active=[indl indu];
ind_inactive=setdiff(1:n,ind_active);

tt=x-x1; 
%tt(iactive)=0;
%if norm(tt)>1e-3
%    x1=x1+tt;
%else
%tt=x-x1;  
tt(ind_inactive)=min(tt(ind_inactive),1);
tt(ind_inactive)=max(tt(ind_inactive),-1);
    x1=x1+tt;
%end



end