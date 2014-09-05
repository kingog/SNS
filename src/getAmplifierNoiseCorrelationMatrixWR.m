function C = getAmplifierNoiseCorrelationMatrixWR(S,gOpt,Rn,Tmin)
% Returns the noise correlation matrix for the amplifier characterized by 
% scattering matrix S, optimal reflection coefficient gOpt, noise 
% resistance Rn, and minimum temperature Tmin

% M = size(S,3);
C = zeros(size(S));
T0 = 290;
Z0 = 50;

Rn = squeeze(Rn);
Tmin = squeeze(Tmin);
gOpt = squeeze(gOpt);

kt = 4*T0*Rn/Z0;
C(1,1,:) = Tmin.*(squeeze(abs(S(1,1,:)).^2 - 1)) + kt.*abs(1-squeeze(S(1,1,:)).*gOpt).^2./abs(1+gOpt).^2;
C(2,2,:) = abs(squeeze(S(2,1,:))).^2.*(Tmin + kt.*abs(gOpt).^2./abs(1+gOpt).^2);
C(1,2,:) = -conj(squeeze(S(2,1,:))).*conj(gOpt).*kt./abs(1+gOpt).^2+squeeze(S(1,1,:)./S(2,1,:).*C(2,2,:));
C(2,1,:) = conj(C(1,2,:));

% 
% for r=1:M
%     
%     kt = 4*T0*Rn(r)/Z0;
%     
%     C(1,1,r) = Tmin(r)*(abs(S(1,1,r))^2 - 1) + kt*abs(1-S(1,1,r)*gOpt(r))^2/abs(1+gOpt(r))^2;
%     C(2,2,r) = abs(S(2,1,r))^2*(Tmin(r) + kt*abs(gOpt(r))^2/abs(1+gOpt(r))^2);
%     C(2,1,r) = -conj(S(2,1,r))*conj(gOpt(r))*kt/abs(1+gOpt(r))^2+S(1,1,r)/S(2,1,r)*C(2,2,r);
%     C(1,2,r) = conj(C(2,1,r));
% 
% end

end