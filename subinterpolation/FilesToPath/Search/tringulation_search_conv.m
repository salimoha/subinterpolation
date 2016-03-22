function [xm ym cse] = tringulation_search_conv(inter_par,xiT,yiT,tri)

global n y0
% Update global interpolation
    %xie=xiT(:,yiT<y_cr); yie=yiT(:,yiT<y_cr);
    %[w,v] = polyharmsp_weight3(xie, yie.',1); tri=delaunayn(xiT.');
ym=inf; 
    for ii=1:size(tri,1)
        Sc(ii)=inf;
        if min(tri(ii,:))>n+1
      [xc,R2]=circhyp(xiT(:,tri(ii,:)), n);
      %[tt,ind]=min(yiT(tri(ii,:))); ind=tri(ii,ind);
         %x=xiT(:,tri(ii,:))*ones(n+1,1)/(n+1);
         x=xiT(:,ind);
         [xm1 ym1 cse]=Adoptive_K_conv(x,inter_par,xc,R2);
         ym1=(interpolate_val(xm1,inter_par)-y0)/(R2-norm(xm1-xc)^2);
         if cse==1
             xm=xm1;
             break
         end
         if (ym1<ym)
             xm=xm1; ym=ym1;
         end
         %Sc(ii)=(interpolate_val(x,inter_par)-y0)/(R2-norm(x-xc)^2);
        end
    end
  %  [t,ind]=min(Sc); [xc,R2]=circhyp(xiT(:,tri(ind,:)), n);
  %  x=xiT(:,tri(ind,:))*ones(n+1,1)/(n+1);
  %  [xm ym cse]=Adoptive_K_conv(x,inter_par,xc,R2);
end


    





