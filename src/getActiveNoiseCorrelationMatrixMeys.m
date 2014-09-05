function C = getActiveNoiseCorrelationMatrixMeys(S,Gopt,Rn,Tmin)
% Returns the noise correlation matrix for the active device characterized 
% by optimal reflection coefficient gOpt, noise resistance Rn, and minimum 
% temperature Tmin

T0 = 290;
Z0 = 50;

Gopt = squeeze(Gopt);
Rn = squeeze(Rn);
Tmin = squeeze(Tmin);

Td = 4*T0*Rn/Z0./(abs(1+Gopt).^2);

C(1,1,:) = Tmin.*squeeze(abs(S(1,1,:)).^2-1)+Td.*(1+abs(Gopt).^2.*squeeze(abs(S(1,1,:)).^2) -2*real(Gopt.*squeeze(S(1,1,:))));
C(2,2,:) = squeeze(abs(S(2,1,:)).^2).*(Tmin + Td.*abs(Gopt).^2);
C(2,1,:) = squeeze(S(2,1,:)).*(squeeze(conj(S(1,1,:))).*Tmin + Td.*(squeeze(conj(S(1,1,:))).*abs(Gopt).^2 - Gopt));
C(1,2,:) = conj(C(2,1,:));

% C(1,1,:) = Td-Tmin;
% C(2,2,:) = squeeze(abs(S(2,1,:)).^2).*(Tmin + Td.*abs(Gopt).^2);
% C(2,1,:) = -squeeze(S(2,1,:)).*Td.*Gopt;
% C(1,2,:) = conj(C(2,1,:));
end