% The Adaoptive K algorithm bound constrained
clear all
close all
clc
global n y0 m bnd1 bnd2 kappa fun rk ss0 y00 Ain bin



kappa=1.2;
setenvAVL
alpha=1;
glo=0;

% specify the objective function
%fun=@alisonfit;
%fun=@fit8;
fun=@plygen;
%fun=@rastriginn;

% parameters
n=10; m=0; meq=0; Np=100; Nr=2; pho=1; y_max=3; y00=0.1;
% interpolaion strategy
inter_method=1;
% upper and lower bouds
ss0=[0.01 1.0472 0.01 0.5 0.1 0.7 0.3 0 0 0].';
ss1=[pi/2 pi/2 pi/2 1.5 0.5 1.5 0.5 1 1 1].';
%ss0=[10 1e-4 10 1e-4 10 1e-4 100 1e-4]';
%ss1=[1000 1 100 2.5 20 1.6 10000 pi/2]';

% the inequality constraints
Ain=[]; bin=[];
% the equlaity constraints
Aeq=[]; beq=[];

% initial calculations
bnd1=zeros(n,1); bnd2=ones(n,1); 
rk=ss1-ss0;

% input the inequality constraints
%Ain=[]; bin=[];
if m~=0
bin=bin-Ain*ss0;
Ain=Ain.*repmat(rk.',m,1);
for ii=1:m
    l=norm(Ain(ii,:));
     Ain(ii,:)=Ain(ii,:)/l;
     bin(ii)=bin(ii)/l;
end
end
m=2*n+m;

% Input the equality constraints
Aeq=[zeros(1,3) ones(1,3) zeros(1,4)]; beq=[2];
if meq~=0
beq=beq-Aeq*ss0;
Aeq=Aeq.*repmat(rk.',meq,1);
x0=Aeq\beq;
V=null(Aeq);
else
    x0=zeros(n,1); V=eye(n);
end


Ain=[Ain; eye(n);-eye(n)];
bin=[bin; bnd2 ;-bnd1];
bin=bin-Ain*x0; Ain=Ain*V;
n=n-meq;

% calculate the initial points
  [xie xic]= Linear_constrained_initilazation(zeros(n,1));
  O=xie*ones(n+1,1)/(n+1);
   xie=[O xie];
   xiT=[xic xie];
   [xiT xie]=inter_add_fix(xiT,xie);
% calculate the function evaluation at initial points

for ii=n+2:size(xiT,2)
    ye=fun([ss0+ (x0+V*xiT(:,ii)).*rk]);
    yiT(ii)=min(ye,y_max);
end
yiT(1:n+1)=inf;
delta=1;
delta_tol=0.2;
Del=[];
for mm=1:2
    y_pre=2+yiT*0;
        for k=1:100
   [xie ,yie ,inde,tri_ind,tri] = neighberpoints_find(xiT,yiT,5);
   if glo==1
 inter_par= interpolateparametarization(xiT(:,n+2:end),yiT(n+2:end),inter_method);
   else
 inter_par= interpolateparametarization(xie,yie,inter_method);
   end
% y_sol(k)=interpolate_val(xx,inter_par);
 [y,ind]=min(yiT); xmin=xiT(:,ind);  
 [xm ym]=inter_min(xmin,inter_par);
    deltam=mindis(xm,xiT);
    if (deltam<delta_tol) 
        y0=(pho*y00+(1-pho)*min(yiT));
        [t,ind]=min(yiT);
        if glo==1
            [xm cse]= tringulation_search_bound(inter_par,xiT,tri);
        else
        [xm cse]=tringulation_search_local(inter_par,xiT,tri_ind ,tri);
        end
         search(k)=1;
    else
        [y,x1,index] = mindis(xm,xiT);
        cse=1;
        search(k)=2;
    end
    if interpolate_val(xm,inter_par)<y00
        y_search=-Inf;
    else
    y_search=(interpolate_val(xm,inter_par)-y00)/mindis(xm,xiT);
    end
    
    if mindis(xm,xiT)<delta_tol
        y_search=inf;
    end
    
    Gps=0;
    [y,ind]=min(yiT);
    [x,y_Gps,Imp] = GPSpollig(inter_par,xiT,xiT(:,ind),delta_tol);
    
    if (y_Gps==Inf && y_search==inf)
        break
    end
    if y_Gps<y_search
    xm=x;
    Gps=1;
    end
    
    if mindis(xm,xiT)>Nr*delta_tol
        [y,x1,index] = mindis(xm,xie);
        xm=xmin+Nr*delta_tol.*(xm-xmin)/norm(xm-xmin);
    end
    [y,ind]=min(yiT);
   % [x,y_Gps] = GPSpollig(inter_par,xiT,xiT(:,ind),delta_tol);
    %if y_Gps<y_search
    %xm=x;
    %end
    xm= lin_convex_bnd_project(xm,xiT,tri);
    %xm=round(20*xm)/20;
    xm=linreflection(xm,Np,1/Np);
    deltam=mindis(xm,xiT(:,n+2:end));
    delta=min(delta,deltam);
    yma=fun(ss0+rk.*(x0+V*xm));
  %  yma=-1/yma
    ymp=interpolate_val(xm,inter_par)
    y_pre=[y_pre ymp];
    [t,ind]=min(yiT);
        xie=[xie xm];
    xiT=[xiT xm];
    yiT=[yiT min(yma,y_max)];
    Del=[Del deltam];
    ym0=min(yiT);
   figure(1)
    subplot(2,1,1)
    plot(1:length(yiT(n+2:end)),yiT(n+2:end),'-',1:length(yiT(n+2:end)),y_pre(n+2:end),'--')
    ylim([0 2])
    subplot(2,1,2)
    plot(xiT(:,n+2:end)')
    drawnow
        end
delta_tol=delta_tol/2;        
end
%[b,ind]=min(yiT);
%xiT1{rr}=repmat(ss0,1,length(yiT))+repmat(rk,1,length(yiT)).*xiT; yiT1{rr}=yiT;
%ssl=ss0+rk.*max(xiT(:,ind)-delta_tol*ones(n,1),bnd1);
%ssU=ss0+rk.*min(xiT(:,ind)+delta_tol*ones(n,1),bnd2);
%ss0=ssl; rk=ssU-ssl;
%clear xiT yiT y_pre y_ac




%if (Im==0 && delta==0.1)
%    break
%end
%xiT=[xiT xi_add];
%yiT=[yiT yi_add];
%Del=[Del delta+0*yi_add];
%end
%[b,ind]=min(yiT);
%xiT1{rr}=repmat(ss0,1,length(yiT))+repmat(rk,1,length(yiT)).*xiT; yiT1{rr}=yiT;
%ssl=ss0+rk.*max(xiT(:,ind)-delta_tol*ones(n,1),bnd1);
%ssU=ss0+rk.*min(xiT(:,ind)+delta_tol*ones(n,1),bnd2);
%ss0=ssl; rk=ssU-ssl;