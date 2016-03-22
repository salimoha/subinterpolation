% Second Order Delta-Dogs:
% Algorithm with second order convergence property.
% Constraints are simple bound constraints.
% Dimenson:
clear all
close all
clc

global n Ain bin y0

n=7;

% objective function:
%fun=@(x) rastriginn(3*(x-[0.3;0]));
%fun=@(x) plygen;
fun= @(x) sum((x-[0.3;0;-0.1;0.8;0.3;0.2;0.1]).^2);
%fun= @(x) sum((x-[0.3;-0.1]).^2)
% Constraints:
lob=zeros(n,1); upb=ones(n,1);

% Estimate of the solution:
y00=0.01;

% Initial Calculation:
bnd1 = lob; bnd2 = upb;
m=2*n;

% maximum number of iterations:
iter_max=40;

% interpolation strategy:
inter_method=1;

% Input the equality constraints
Ain=[eye(n);-eye(n)]; bin=[bnd2 ;-bnd1];

% Calculate the Initial trinagulation points
xU=bounds(bnd1,bnd2, n);
% Calculate initial delta
xE=(bnd1+bnd2)/2;

% initial points: the midpoint point and its neighber
delta0=0.1;
for ii=1:n
    e=zeros(n,1); e(ii)=1;
    xE(:,ii+1)=xE(:,1)+delta0*e;
end

% Calculate initial unevaluated delta
for ii=1:size(xU,2)
    deltaU(ii)=mindis(xU(:,ii),xE);
end
% Calculate the function at initial points
for ii=1:size(xE,2)
    yE(ii)=fun(xE(:,ii));
end


% Initialize constaints 
tol=0.05;

for k=1:iter_max
            inter_par= interpolateparametarization(xE,yE,inter_method);
% check the unevaluated points
y0=0.5*min(yE)+0.5*y00;
%y0=y00;
            clear yup
            for ii=1:size(xU,2)
               yup(ii)=interpolate_val(xU(:,ii),inter_par);
            end
% check the minimum value of xE
[t,ind]=min(yup);
  if t<y0
      x=xU(:,ind);
% the case when xU has imporved point.
   delta=mindis(x,xE);
     if delta<tol
       break
     else
       xE=[xE x]; yE=[yE fun(x)];
       xU(:,ind)=[]; deltaU(ind)=[];
     end
  else
     %tri=delaunayn([xE,xU]');
     [xm ]= tringulation_search_bound(inter_par,[xE xU]);
     [x,xE,xU,deltaU,newadd]=points_neighbers_find(xm,xE,xU,deltaU);
     x=round(x*20)/20;
  %   keyboard
     if newadd 
        delta=mindis(x,xE);
        if delta<tol
            break
        else
           xE=[xE x];
           yE=[yE fun(x)];
        end
     end
     figure(1)
    subplot(2,1,1)
    plot(1:length(yE),yE,'-')
    ylim([0 1])
    xlim([0 40])
    subplot(2,1,2)
    plot(xE')
    xlim([0 40])
    drawnow
      %plot(xi(1,:)0,xi(2,:),'rs')
           
  end
end

