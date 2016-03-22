function [xm ym cse] = tringulation_search_bound(inter_par,xiT,yiT)

global n y0
%keyboard
[xm,ym]=inter_min(xiT(:,end),inter_par);
if (ym>y0)
[t,ind]=min(yiT);
ym=inf; cse=2; 
tri=delaunayn(xiT.');
    for ii=1:size(tri,1)
      [xc,R2]=circhyp(xiT(:,tri(ii,:)), n);
         x=xiT(:,tri(ii,:))*ones(n+1,1)/(n+1); 
        % [x,ym]=Adoptive_K_Search(x,inter_par,xc,R2); 
         Sc(ii)=(interpolate_val(x,inter_par)-y0)/(R2-norm(x-xc)^2);
        % [x,ym]=Adoptive_K_Search(x,inter_par,xc,R2); 
        if ismember(ind,tri(ii,:))
            Scl(ii)=Sc(ii);
        else
            Scl(ii)=inf;
        end
    end
    [t,ind]=min(Sc); [xc,R2]=circhyp(xiT(:,tri(ind,:)), n);
    x=xiT(:,tri(ind,:))*ones(n+1,1)/(n+1);
    [xm,ymg]=Adoptive_K_Search(x,inter_par,xc,R2);  
    [t,ind]=min(Scl); [xc,R2]=circhyp(xiT(:,tri(ind,:)), n);
    x=xiT(:,tri(ind,:))*ones(n+1,1)/(n+1);
    [xml, yml]=Adoptive_K_Search(x,inter_par,xc,R2);
if yml<2*ymg
    xm=xml;
end
    end

end
    





