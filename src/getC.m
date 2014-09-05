function c = getC(cn)
% Calculates the c vector for the N-port device that cn is connected to
% twice. Just the formula for what happens when ports k and m of an N-port
% device are connected to each other.
cm = cn.Nf.c;
S = cn.Nf.S;
N = size(Sm,1);
Nlist = [1:N];

k = cn.Nfp;
l = cn.Nbp;
% List of ports other than two interconnected ones
Nlisti = Nlist(Nlist ~= k & Nlist ~= l);

for i=Nlisti
    % update every element except k and l
    cm(i,:,:) = cm(i,:,:) + ((S(i,l,:)*S(k,k,:)+S(i,k,:)*(1-S(k,l,:)))*cm(l,:,:)+...
        (S(i,k,:)*S(l,l,:)+S(i,l,:)*(1-S(l,k,:)))*cm(k,:,:))/...
        ((1-S(k,l,:))*(1-S(l,k,:))-S(k,k,:)*S(l,l,:));
end

% Remove rows and columns k and l
c = cm(Nlisti,:,:);
end