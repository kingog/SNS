function [P,Bm] = getOutputNoise(cj,cvectors,Cmatrices,num)
% This function calculates the output noise power in expression cj for each
% component in the cells cvectors and Cmatrices. If num == 1 then use
% numeric quantities, else use doubles

M = length(cvectors); % Number of components
N = size(cj,3); % Number of frequency points
if num == 0
    P = sym(zeros(M,1,N));
else
    P = zeros(M,1,N);
end
for k=1:M
    c = cvectors{k};
    C = Cmatrices{k};
    % Form the b vector:
    if num == 0
        b = sym(zeros(size(c,1),1,N));
    else
        b = zeros(size(c,1),1,N);
    end
    
    for r=1:size(c,1)
        b(r,1,:) = (diff(cj,c(r,1)));
    end
    % Now form the B matrix    
    if num == 0
        B = sym(zeros(size(C)));
    else
        B = zeros(size(C));
    end
    for s=1:N
        B(:,:,s) = kron(b(:,1,s),b(:,1,s)');
    end
    Bm{k} = B;
    % Finally, produce the power contributed by component k:
    P(k,1,:) = (sum(sum(B.*C,1),2));
end

end