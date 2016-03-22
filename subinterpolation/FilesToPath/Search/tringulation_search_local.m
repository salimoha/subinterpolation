function [xm cse ym] = tringulation_search_local(inter_par,xiT,tri_ind,tri)

global n bnd1 bnd2 y0
ym=inf; yml=inf; cse=2;
    for ii=1:length(tri_ind)
        ind=tri_ind(ii);
      [xc,R2]=circhyp(xiT(:,tri(ind,:)), n);
          x=xiT(:,tri(ind,:))*ones(n+1,1)/(n+1);
         Sc(ii)=(interpolate_val(x,inter_par)-y0)/(R2-norm(x-xc)^2);
    end
      [t,ind]=min(Sc);
      ind=tri_ind(ind);
      [xc,R2]=circhyp(xiT(:,tri(ind,:)), n);
      x=xiT(:,tri(ind,:))*ones(n+1,1)/(n+1);
      [xm ym cse]=Adoptive_K_Search(x,inter_par,xc,R2);
    if cse==1
       xm=inter_min(xm, inter_par);
    end
    
end