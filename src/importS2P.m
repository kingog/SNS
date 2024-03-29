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

end