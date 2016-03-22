function [xiT,xie] = inter_add_fix(xiT,xie)
% Fixing the initial problem for convex initialization
global n Ain bin
while 1
ff=[];
tri=delaunayn(xiT.');
for ind=1:size(tri,1)
  if ismember(n+2,tri(ind,:))
      ff= union(ff,tri(ind,:));
  end
end 
ff=ff(ff<n+2);
if length(ff)==0
    break
else
for ind=1:length(ff)
    c=bin-Ain*xiT(:,n+2);
    d=Ain*(xiT(:,ff(ind))-xiT(:,n+2));
    alpha=c./d;
    alpha=min(alpha(d>0));
   xic(:,ind)=xiT(:,n+2)+alpha*(xiT(:,ff(ind))-xiT(:,n+2));
end
xiT=[xiT xic];
xie=[xie xic];
end
end

end

