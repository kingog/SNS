function C = getAmplifierNoiseCorrelationMatrix(S,Tg,Td)
% Returns the noise correlation matrix for the amplifier characterized by 
% scattering matrix S, with parameters Tg and Td.
M = size(S,3);
C = zeros(size(S));
for r=1:M
    C(1,1,r) = Tg*(1-abs(S(1,1,r))^2);
    C(2,1,r) = conj(S(2,1,r)/(S(1,1,r)-1)*C(1,1,r));
    C(1,2,r) = conj(C(2,1,r));
    C(2,2,r) = abs(S(2,1,r))^2/abs(1-S(1,1,r))^2*C(1,1,r) + Td*(1-abs(S(2,2,r))^2);
end
end