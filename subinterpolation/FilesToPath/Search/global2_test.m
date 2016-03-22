clear all
close all
clc
% script to test the global 2 paper
global n m y0 cons

kappa=1.5;
alpha=1;
glo=0;
m=2;
y0=0.4;

% specify the objective function
fun=@rastriginn;
x0=[sqrt(2) ;-sqrt(2)];
cons(1).val=@(x) 4-norm(x-x0)^2; cons(1).grad=@(x) 2*(x-x0); cons(1).Hess=@(x) 2*eye(2,2);
cons(2).val=@(x) sqrt(2)-[1 0]*x; cons(2).grad=@(x) [0;0]; cons(2).Hess=@(x) zeros(2,2);
% parameters
n=2; 
% interpolaion strategy
inter_method=1;
% upper and lower bouds

% calculate the initial points
 xie=[-2 0 0; 0 -2 2];
 x0=[sqrt(2) -sqrt(2)];
 xie(1,:)=xie(1,:)+x0(1);
 xie(2,:)=xie(2,:)+x0(2);
 O=xie*ones(n+1,1)/(n+1);
 for k=1:n+1
tt=xie*ones(n+1,1)-n*xie(:,k); 
xic(:,k)=O+kappa*(tt-O);
end
xiT=[xic O xie]; 

% calculate the function evaluation at initial points

for ii=n+2:size(xiT,2)
    yiT(ii)=fun(xiT(:,ii));
end
yiT(1:n+1)=inf;
delta=1; delta_tol=0.05; Del=[];


for k=1:1
   
 inter_par= interpolateparametarization(xiT(:,n+2:end),yiT(n+2:end),inter_method);
% y_sol(k)=interpolate_val(xx,inter_par);
 [y,ind]=min(yiT); xmin=xiT(:,ind);  
 [xm]=inter_min_conv(xmin,inter_par);
    if (interpolate_val(xm,inter_par)>y0) 
           tri=delaunayn(xiT.');
           [xm cse]= tringulation_search_conv(inter_par,xiT,yiT,tri);
    end
   % keyboard
    xm= convex_bnd_project(xm,xiT,tri);
xiT=[xiT xm];
yiT=[yiT fun(xm)];

end
theta=pi/2:0.01:3*pi/2;
xx=x0(1)+2*cos(theta); yy=x0(2)+2*sin(theta);
plot(0,0,'k*')
hold on
plot(xx,yy,'r-')
hold on
plot(xiT(1,n+2:end),xiT(2,n+2:end),'ks')
%xlim([sqrt(2)-2 sqrt(2)])
%ylim([-sqrt(2)-2 2-sqrt(2)])
plot(xx,yy,'r-')
        

