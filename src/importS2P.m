function [f,S] = importS2P(fname)
% [f,S] = importS2P(fname)
% This function imports an S2P file. At the moment there is only support
% for S parameter files with a 50 Ohm impedance.

[UNITS,form,hlines] = getSNPheader(fname);
d = importdata(fname, ' ', hlines);

N = size(d.data,1);
f = zeros(N,1);
S = zeros(2,2,N);
for k=1:N
    D = d.data(k,:);
    f(k) = D(1,1)/UNITS;
    D = D(:,2:end);
    Sm = [D(1,1:2) D(1,5:6); D(1,3:4) D(1,7:8)];
    switch form
        case 'MA'
            S(:,:,k) = Sm(:,1:2:end-1).*exp(1i*Sm(:,2:2:end)*pi/180);
        case 'DB'
            S(:,:,k) = 10.^(Sm(:,1:2:end-1)/20).*exp(1i*Sm(:,2:2:end)*pi/180);
        case 'RI'
            S(:,:,k) = Sm(:,1:2:end-1) + 1i*Sm(:,2:2:end);
        otherwise
            disp('ERROR INTERPRETING S PARAMETER FORMAT')
    end
            
end



% % Import the Touchstone S2P file found in fname
% d = textread(fname,'','commentstyle','shell');
% if sum(d(:,end)) == 0
%     d = d(:,1:end-1);
% end
% 
% f = d(:,1);
% a = d(:,2:9);
% 
% % Cols of a are:
% % <S11>(mag, phase) <S21>(mag, phase) <S12>(mag, phase) <S22>(mag, phase)
% 
% M = a(:,1:2:7).*exp(1i*a(:,2:2:8)*pi/180);
% % Cols of M are:
% % S11 S21 S12 S22
% 
% % Put frequency in the third dimension:
% Ms = permute(M,[2,3,1]);
% % Now we have:
% % [S11; S21; S12; S22]
% S = reshape(Ms,2,2,size(Ms,3));




end