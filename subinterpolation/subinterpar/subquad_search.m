function [y, abc]= subquad_search(x,e,xi,yi,K)
% This function generates the subinterpolation at the point point x using
% the 1d qudratic interpolation for its weighted basises.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% keyboard
% p(x)=ax^2+bx+c
N = size(xi,2);

n=size(xi,1);

A1 = [xi.^2 ;xi; ones(1,N)]';

Ain=[A1; -A1];
Ain=[Ain; -1 0 0];
bin=[yi'; -min(yi)*ones(N,1); 0];
abc=[0 ;0 ;min(yi)];  % wv = [min(yi); zeros(n,1)]; %v
Phi_x=[x^2 x 1];
%optimize over w and v
while 1
%     keyboard
    % find y and Dy
    y=Phi_x*abc-K*abc(1)*e;
%     y=interpolate_val(x,inter_par)-K*sum(abs(inter_par{2}))*e;
    %for ii=1:N
%         Dyw(ii)=norm(x-xi(:,ii))^3-K*e*sign(inter_par{2}(ii));
    Dy=Phi_x'-K*e*[1 ;0 ;0]; 
    %end
%     w = inter_par{2};
%     v = inter_par{3};
%     wv = [w;-w ;v;-v]
%       wv = [w;v]
options = optimoptions('linprog','Algorithm','dual-simplex');
    [dx,fval,exitflag,output,lambda] = linprog(Dy',Ain,bin-Ain*abc,[],[],[],[],zeros(3,1),options);
    if norm(dx)<1e-3
        break
    else
         abc=abc+dx;% v=v+dx(1:n+1);
%         wv = wv +dx;
    end
    
end

end
