function [inter_par,yp]= regressionparametarization(xi,yi,sigma,inter_method)
n=size(xi,1);
N=size(xi,2);

%while 1
if inter_method==1
   % keyboard
    A = zeros(N,N);
  % calculate regular A matrix for polyharmonic spline
for ii = 1 : 1 : N
    for jj = 1 : 1 : N
        A(ii,jj) = ((xi(:,ii) - xi(:,jj))' * (xi(:,ii) - xi(:,jj))) ^ (3 / 2);
    end
end

V = [ones(1,N); xi];
w1= diag(1./sigma)*V'\(yi./sigma).'; b=mean(((V'*w1-yi.')./sigma').^2);

%keyboard
if b<1
   % keyboard
    wv(1:N)=0; wv(N+1:N+n+1)=w1; rho=1000;
    wv=wv.';
else
    rho=1.1;
    options = optimset('Jacobian','on','display','none');
    fun=@(rho) smoothing_polyharmonic(rho,A,V,sigma,yi,n,N);
    rho = fsolve(fun,rho,options);
    [b,db,wv]=fun(rho);
    
end




inter_par{1}=1;
inter_par{2} = wv(1:N); inter_par{3} = wv(N+1:N+n+1); 
inter_par{4}= xi;

 while 1
     for ii=1:N
       yp(ii)=interpolate_val(xi(:,ii),inter_par);
     end
     if max(abs(yp-yi)./sigma)<2
         break
     end
     rho=rho*0.9;
     [b,db,wv]=smoothing_polyharmonic(rho,A,V,sigma,yi,n,N);
     inter_par{2} = wv(1:N); inter_par{3} = wv(N+1:N+n+1); 
 end
end
 %end
if inter_method==2
    inter_par=[]; yp=[];
 disp(sprintf( 'Wrong Interpolation method') );
end
end

function [b,db,wv]=smoothing_polyharmonic(rho,A,V,sigma,yi,n,N)
 A1 = [A+rho*diag(sigma.^2) V'; V zeros(n+1,n+1)];
 wv= A1 \ [yi.'; zeros(n+1,1)]; b=mean((wv(1:N).*sigma').^2*rho^2)-1;
 Dwv=-A1 \ [wv(1:N).*(sigma.^2)' ;zeros(n+1,1)]; db=2*mean((wv(1:N).^2*rho+rho^2*wv(1:N).*Dwv(1:N)).*(sigma.^2).');
end