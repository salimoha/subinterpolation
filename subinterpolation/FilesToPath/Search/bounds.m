function bnds = bounds(bnd1,bnd2, n)


bnds = repmat(bnd2,1,2^n);

for ii = 0 : 1 : n - 1
    bnds(ii+1,mod(1:2^n,2^(n-ii))+1 <= 2^(n-ii-1)) = bnd1(ii+1);
end
