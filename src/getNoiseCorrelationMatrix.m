function C = getNoiseCorrelationMatrix(S,T)
% Returns the noise correlation matrix for the passive component
% characterized by scattering matrix S, at physical temperature T [K].
M = size(S,3);
C = zeros(size(S));
for r=1:M
    C(:,:,r) = (eye(size(S,1),size(S,2))-S(:,:,r)*S(:,:,r)')*T;
end
end