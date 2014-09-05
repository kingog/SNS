function C = getAmplifierNoiseCorrelationMatrixDob(S,gOpt,Rn,Tmin)
% Returns the noise correlation matrix for the amplifier characterized by 
% scattering matrix S, optimal reflection coefficient gOpt, noise 
% resistance Rn, and minimum temperature Tmin
%
% As specified in Dobrowolski (1989)
% M = size(S,3);
C = zeros(size(S));
T0 = 290;
Z0 = 50;

gOpt = squeeze(gOpt);
Rn = squeeze(Rn);
Tmin = squeeze(Tmin);

Fem = Tmin/T0;
Go = real(1/Z0*(1-gOpt)./(1+gOpt));
N = 4*Rn.*Go;

C0 = T0./(1-abs(gOpt).^2);
C(1,1,:) = C0.*((Fem+(N-Fem).*abs(gOpt).^2).*abs(squeeze(S(1,1,:))).^2+...
    2*N.*real(gOpt.*squeeze(S(1,1,:)))+N-Fem.*(1-abs(gOpt)));
C(2,1,:) = C0.*( (Fem+(N-Fem).*abs(gOpt).^2).*squeeze(conj(S(1,1,:)).*S(2,1,:))+...
    N.*gOpt.*squeeze(S(2,1,:)) );
C(1,2,:) = conj(C(2,1,:));
C(2,2,:) = C0.*((Fem+(N-Fem).*abs(gOpt).^2).*abs(squeeze(S(2,1,:))).^2);

% for r=1:M
%     
%     Fem = 1+Tmin(r)/T0;
%     Go = real(1/Z0*(1-gOpt(r))/(1+gOpt(r)));
%     N = 4*Rn(r)*Go;
%     
%     C0 = T0/(1-abs(gOpt(r))^2)/2;
%     C(1,1,r) = C0*((Fem+(N-Fem)*abs(gOpt(r))^2)*abs(S(1,1,r))^2 +2*N*real(gOpt(r)*S(1,1,r))+N -Fem*(1-abs(gOpt(r))));
%     C(2,1,r) = C0*( (Fem+(N-Fem)*abs(gOpt(r))^2)*conj(S(1,1,r))*S(2,1,r) +N*gOpt(r)*S(2,1,r) );
%     C(1,2,r) = conj(C(2,1,r));
%     C(2,2,r) = C0*((Fem+(N-Fem)*abs(gOpt(r))^2)*abs(S(2,1,r))^2);
% end
end