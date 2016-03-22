function [s]= subinterpolate_search(x,e,xi,yi,K)
% sub

N = size(xi,2);
bin=[yi; -min(yi)*ones(N,1)];
n=size(xi,1);


%keyboard

 A = zeros(N,N);
for ii = 1 : 1 : N
    for jj = 1 : 1 : N
        A(ii,jj) = ((xi(:,ii) - xi(:,jj))' * (xi(:,ii) - xi(:,jj))) ^ (3 / 2);
    end
end
%keyboard
V = [ones(1,N); xi];
Aeq=[ V zeros(n+1,n+1)]; beq=zeros(n+1,1);
A1=[ A V']; Ain=[A1 -A1];

inter_par{1}=1;
inter_par{2} = zeros(N,1); 
inter_par{3} = [min(yi) zeros(n,1)]; 
inter_par{4}= xi;
%optimize over w and v
while 1
    
    % find y and Dy
    y=interpolate_val(x,inter_par)-K*sum(abs(inter_par{2}))*e;
    for ii=1:N
        Dyw(ii)=norm(x-xi(:,ii))^3-K*e*sign(w(ii));
    end
    Dyv(1)=1;
    for jj=2:n+1
        Dyv(ii)=x(ii);
    end
    dx = linprog([Dyw Dyv],Ain,bin-Ain*[w ;v],Aeq,0,[],[],zeros(N+n+1,1));
    if norm(dx)<1e-3
        break
    else
        w=w+dx(1:N); v=v+dx(1:n+1);
    end
    
end

end
