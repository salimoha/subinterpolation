function [xm,pm] = tringulation_search_bound1(inter_par,xi)

global n y0 
 %   [xm,ym]=inter_min(xi(:,end),inter_par);
    
%if ym>0
if 1 
tri=delaunayn(xi.');   ym=inf; cse=2;
    for ind=1:size(tri,1)
        if min(tri(ind,:))>n+1
     % keyboard
            [xc,R2]=circhyp(xi(:,tri(ind,:)), n);
      if R2<1000
       x=xi(:,tri(ind,:))*ones(n+1,1)/(n+1);
 %      yss=yi(tri(ind,:))*ones(n+1,1)/(n+1);
       %y=(interpolate_val(x,inter_par)+yss-y0)/(R2-norm(x-xc)^2);
     %  x=Adoptive_K_Search(x,inter_par,xc,R2);
       y=(interpolate_val(x,inter_par)-y0)/(R2-norm(x-xc)^2);
      if (y<ym)
          ym=y; xm=x; indm=ind;
      end
      end
        end
    end
%  %  keyboard
   %[xm,pm]=quadtaic_simplex_Search(xm,inter_par,xi(:,tri(indm,:)),yi(:,tri(indm,:)));
    [xc,R2]=circhyp(xi(:,tri(indm,:)), n);
    xm=xi(:,tri(indm,:))*ones(n+1,1)/(n+1); 
    xm=Adoptive_K_Search(xm,inter_par,xc,R2);
%else
%   [xm]=min_decrease(x0, xm, inter_par); 
end
end