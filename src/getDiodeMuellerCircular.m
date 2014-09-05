function [MI,MQ,MU,MV] = getDiodeMuellerCircular(SL,SR)
% [MI,MQ,MU,MV] = getDiodeMuellerCircular(SL,SR)
% This function returns the Mueller matrix elements for a detector diode,
% when SL is the scattering matrix contribution from EL, and SR from ER
%
MI = 1/2*(SL*conj(SL) + SR*conj(SR));
MV = 1/2*(SL*conj(SL) - SR*conj(SR));
MQ = 1/2*(SL*conj(SR) + SR*conj(SL));
MU = 1i/2*(SL*conj(SR) - SR*conj(SL));
end