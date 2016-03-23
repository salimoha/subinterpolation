function [y, lambda, w,v]= subinterpolate_search(x,e,xi,yi,K)
% This function generates the subinterpolation at the point point x using
% the polyharmonic spline interpolation for its weighted basises.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% keyboard
N = size(xi,2);

n=size(xi,1);

A = zeros(N,N);
for ii = 1 : 1 : N
    for jj = 1 : 1 : N
        A(ii,jj) = ((xi(:,ii) - xi(:,jj))' * (xi(:,ii) - xi(:,jj))) ^ (3 / 2);
    end
end
%keyboard
V = [ones(1,N); xi];

Aeq=[ V zeros(n+1,n+1)]; beq=zeros(n+1,1);
A1=[ A V']; 
Ain=[A1; -A1];
bin=[yi'; -min(yi)*ones(N,1)];
w = zeros(N,1);  % w
v = [min(yi); zeros(n,1)]; %v
for ii=1:N
Phi_x(ii)= norm(x-xi(:,ii))^3;
end
V_x=[1 x'];
%optimize over w and v
while 1
    keyboard
    % find y and Dy
    y=Phi_x*w+V_x*v-K*sum(abs(w))*e;
%     y=interpolate_val(x,inter_par)-K*sum(abs(inter_par{2}))*e;
    %for ii=1:N
%         Dyw(ii)=norm(x-xi(:,ii))^3-K*e*sign(inter_par{2}(ii));
    Dyw=Phi_x'-K*e*sign(w); 
    %end
    Dyv=V_x';
%     w = inter_par{2};
%     v = inter_par{3};
%     wv = [w;-w ;v;-v]
%       wv = [w;v]
options = optimoptions('linprog','Algorithm','dual-simplex');
    [dx,fval,exitflag,output,lambda] = linprog([Dyw ;Dyv]',Ain,bin-Ain*[w;v],Aeq,beq,[],[],zeros(N+n+1,1),options);
    if norm(dx)<1e-3
        break
    else
         w=w+dx(1:N);% v=v+dx(1:n+1);
         v=v+dx(N+1:end);
%         wv = wv +dx;
    end
    
end

end
