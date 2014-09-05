function C = getActiveNoiseCorrelationMatrix(S,gOpt,Rn,Tmin)
% Returns the noise correlation matrix for the active device characterized 
% by optimal reflection coefficient gOpt, noise resistance Rn, and minimum 
% temperature Tmin

T0 = 290;
Z0 = 50;

Rn = squeeze(Rn)/Z0;
Tmin = squeeze(Tmin);
gOpt = squeeze(gOpt);

Fmin = 1+Tmin/T0;

Ta = (Fmin-1)*T0 + 4*T0*Rn.*(abs(gOpt).^2)./(abs(1+gOpt).^2);
Tb = 4*T0*Rn./(abs(1+gOpt).^2)-(Fmin-1)*T0;
Tc = 4*T0*Rn.*abs(gOpt)./(abs(1+gOpt).^2);
phic = pi-angle(gOpt);

C(1,1,:) = abs(squeeze(S(1,1,:))).^2.*Ta+Tb+2*real(squeeze(S(1,1,:)).*Tc.*exp(-1j*phic));
C(2,2,:) = squeeze(abs(S(2,1,:)).^2).*Ta;
C(1,2,:) = squeeze(S(1,1,:).*conj(S(2,1,:))).*Ta + squeeze(conj(S(2,1,:))).*Tc.*exp(1j*phic);
C(2,1,:) = conj(C(1,2,:));

% C(1,1,:) = Ta;
% C(2,2,:) = Tb;
% C(2,1,:) = Tc.*exp(-1j*phic);
% C(1,2,:) = Tc.*exp(1j*phic);
% 
% T = [S(1,1,:) ones(size(S(1,1,:))); S(2,1,:) zeros(size(S(1,1,:)))];
% 
% C2p = zeros(size(S));
% for k=1:size(S,3)
%     C2p(:,:,k) = T(:,:,k)*C(:,:,k)*(T(:,:,k)');
% end
% 
% C2p(1,1,:) = abs(C2p(1,1,:));
% C2p(2,2,:) = abs(C2p(2,2,:));

end