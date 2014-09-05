function P = getOutputNoise(cj,cvectors,Cmatrices)
% This function calculates the output noise power in expression cj for each
% component in the cells cvectors and Cmatrices

M = length(cvectors); % Number of components
N = size(cj,3); % Number of frequency points
P = zeros(M,1,N);
for k=1:M
    c = cvectors{k};
    C = Cmatrices{k};
    % Form the b vector:
    b = zeros(size(c,1),1,N);
    for r=1:size(c,1)
        b(r,1,:) = double(diff(cj,c(r,1)));
    end
    % Now form the B matrix
    B = zeros(size(C));
    for s=1:N
        B(:,:,s) = kron(b(:,1,s),b(:,1,s)');
    end
    % Finally, produce the power contributed by component k:
    P(k,1,:) = abs(sum(sum(B.*C,1),2));
end

end