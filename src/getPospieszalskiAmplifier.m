function [S,C] = getPospieszalskiAmplifier(f,Z0,Cgs,rgs,rds,gm0,gt,Tg,Td)
% [S,C] = getPospieszalskiAmplifier(f,Z0,Cgs,rgs,rds,gm,Tg,Td)

w = reshape(2*pi*squeeze(f),[1,1,length(f)]);
gm = gm0.*exp(-1j*w*gt);

S(1,1,:) = (1+1j*w*Cgs*(rgs-Z0))./(1+1j*w*Cgs*(rgs+Z0));
S(2,1,:) = -2*gm*rds*Z0./((rds+Z0).*(1+1j*w*Cgs*(rgs+Z0)));
S(2,2,:) = (rds-Z0)./(rds+Z0);
S(1,2,:) = 0;

C(1,1,:) = 4*Tg*rgs*Z0*w.^2*Cgs^2./(1+w.^2*Cgs^2*(rgs+Z0)^2);
C(2,1,:) = -1j*4*Tg*rgs*rds*Z0*w*Cgs.*gm./(1+w.^2*Cgs^2*(rgs+Z0)^2);
C(1,2,:) = conj(C(2,1,:));
C(2,2,:) = 4*Tg*rgs*rds*Z0*gm.^2./(1+w.^2*Cgs^2*(rgs+Z0)^2) + 4*Td*rds*Z0./(rds+Z0).^2;

end