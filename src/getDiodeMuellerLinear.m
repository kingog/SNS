function [MI,MQ,MU,MV] = getDiodeMuellerLinear(SX,SY)
% [MI,MQ,MU,MV] = getDiodeMuellerLinear(SX,SY)
% This function returns the Mueller matrix elements for a detector diode,
% when SX is the scattering matrix contribution from EX, and SY from EY
%
N = size(SX,3);
MI = sym(zeros(1,1,N));
MQ = sym(zeros(1,1,N));
MU = sym(zeros(1,1,N));
MV = sym(zeros(1,1,N));
for k = 1:N
    MI(k) = 1/2*(SX(k)*conj(SX(k)) + SY(k)*conj(SY(k)));
    MQ(k) = 1/2*(SX(k)*conj(SX(k)) - SY(k)*conj(SY(k)));
    MU(k) = 1/2*(SX(k)*conj(SY(k)) + SY(k)*conj(SX(k)));
    MV(k) = 1i/2*(SX(k)*conj(SY(k)) - SY(k)*conj(SX(k)));
end

end
