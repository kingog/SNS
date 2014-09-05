function [f,S] = importS4P(fname)
% [f,S] = importS4P(fname)
% This function imports an S4P file. At the moment there is only support
% for S parameter files with a 50 Ohm impedance.

[UNITS,form,hlines] = getSNPheader(fname);
% Import the file
d = importdata(fname, ' ', hlines);

N = size(d.data,1)/4;
f = zeros(N,1);
S = zeros(4,4,N);
for k=1:N
    D = d.data((4*k-3):(4*k),:);
    f(k) = D(1,1)/UNITS;
    Sm = [D(1,2:end); D(2,1:end-1); D(3,1:end-1); D(4,1:end-1)];
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