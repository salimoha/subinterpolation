function [xm ym] = tringulation_search_bound_constantK(inter_par,xi,K,ind_min)
global n

tri=delaunayn(xi.');
%keyboard
    % Search over the simplices
    for ii=1:size(tri,1)
      [xc,R2]=circhyp(xi(:,tri(ii,:)), n);
      x=xi(:,tri(ii,:))*ones(n+1,1)/(n+1); 
         Sc(ii)=interpolate_val(x,inter_par)-K*(R2-norm(x-xc)^2); 
        if ismember(ind_min,tri(ii,:))
            Scl(ii)=Sc(ii);
        else
            Scl(ii)=inf;
        end
    end
  %  keyboard
    % global one
    [t,ind]=min(Sc); [xc,R2]=circhyp(xi(:,tri(ind,:)), n);
    x=xi(:,tri(ind,:))*ones(n+1,1)/(n+1);
    [xm,ym]=Constant_K_Search(x,inter_par,xc,R2,K);  
    % local one
    [t,ind]=min(Scl); [xc,R2]=circhyp(xi(:,tri(ind,:)), n);
    x=xi(:,ind_min);
   % keyboard
    [xml, yml]=Constant_K_Search(x,inter_par,xc,R2,K);
    
    % Replace if it is necessary
    if yml<ym
        xm=xml;
        ym=yml;
    end
end

% Search inside a Simplex.

function [x y]=Constant_K_Search(x0,inter_par,xc,R2,K)

global lb ub
%keyboard
costfun=@(x) Contious_search_cost(x,inter_par,xc,R2,K);
options = optimoptions('fmincon','algorithm','active-set','display','none','GradObj','on');
[x,y]=fmincon(costfun,x0,[],[],[],[],lb,ub,[],options);

end

function [M,DM]=Contious_search_cost(x,inter_par,xc,R2,K)
M=interpolate_val(x,inter_par)-K*(R2-norm(x-xc)^2);
 if nargout>1
    DM=interpolate_grad(x,inter_par)+2*K*(x-xc);
 end
end



    