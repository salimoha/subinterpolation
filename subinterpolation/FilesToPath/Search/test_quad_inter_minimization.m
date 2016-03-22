% Test the Delta-Dogs with consant Hessian


clear all
close all
clc
global n m bnd1 bnd2 Ain bin acon y0 r xi tri


n=1;
r=3;
%kpar=1000;
%kpar=90
kpar=1;
%fun=@(x) (x-0.3).^2;
fun=@(x) rastriginn(6*(x-0.4));
%fun=@(x) (x-0.2)^2/(0.25-(x-0.5)^2+0.01);
lob=zeros(n,1); upb=ones(n,1);
y0=0.1;
bnd1 = lob;
bnd2 = upb;
m=2*n;

iter_max=10;
inter_method=1; % Diagonal Hessian interpolation
% upper and lower bouds

% Input the equality constraints
Ain=[eye(n);-eye(n)]; bin=[bnd2 ;-bnd1];
% Calculate the initial points
xi=bounds(bnd1,bnd2, n);
% Calculate the function evaluation at initial points

% Initialize constaints 
for ii=1:m
    acon{ii}=[];
end

for ii=1:size(xi,2)
    ind=1:2*n;
    ind=ind(Ain*xi(:,ii)-bin>-0.01);
    for jj=1:length(ind)
    acon{ind(jj)}=[acon{ind(jj)} ii];
    end
    yi(ii)=fun(xi(:,ii));
end

delta_tol=0.01;

xi(1,1)=xi(1,1)+0.01; % bc it couldn't calculate deluany triangulation
for k=1:iter_max
    
            tri=delaunayn(xi.');
     if k<kpar
         inter_method=1;
     else
         inter_method=3;
     end
            inter_par= interpolateparametarization(xi,yi,inter_method);
         
      % Visulization in 1D
      if n==1
      xv=bnd1(1):0.01:bnd2(1);
      for ii=1:length(xv)
          yp(ii)=interpolate_val(xv(ii),inter_par);
          yr(ii)=fun(xv(ii));  
      end
      figure(k) 
      clf
      plot(xv,yp,'b-');
      hold on
      plot(xv,yr,'k-');
      if n==1
      plot(xi,yi,'ks')
      end
      end
%    keyboard
tri=delaunayn(xi.');
           [xm ym(k) Cs(k)]= tringulation_search_bound(inter_par,xi,tri)
           [xm]=feasible_constraint_box(xm,xi,length(xi)+1);
           if mindis(xm,xi)<delta_tol
               break
           end
      %plot(xi(1,:)0,xi(2,:),'rs')
            xi=[xi xm];
            yi=[yi fun(xm)];
            if n==1
               plot(xm,fun(xm),'rs')
            end
           
end