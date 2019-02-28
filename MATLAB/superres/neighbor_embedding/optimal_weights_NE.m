function W = optimal_weights_NE(XT, XS)
K = size(XS,2);
XT = XT(:);

tol=1e-4; % regularlizer in case constrained fits are ill conditioned

z = XS - repmat(XT,1,K);
C = z'*z;
if trace(C)==0
    C = C + eye(K,K)*tol;                   % regularlization
else
    C = C + eye(K,K)*tol*trace(C);
end
W = C\ones(K,1);               % solve C*u=1
W = W/sum(W);                  % enforce sum(u)=1