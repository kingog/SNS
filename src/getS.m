function S = getS(cn)
Sm = cn.Nf.S;
N = size(Sm,1);
Nlist = [1:N];

k = cn.Nfp;
l = cn.Nbp;
Nlisti = Nlist(Nlist ~= k & Nlist ~= l);

Sil = repmat(Sm(:,l,:),[1,N,1]);
Sik = repmat(Sm(:,k,:),[1,N,1]);
Skj = repmat(Sm(k,:,:),[N,1,1]);
Slj = repmat(Sm(l,:,:),[N,1,1]);

A = (Sil.*Skj.*(1-repmat(Sm(l,k,:),N,N))+Sil.*repmat(Sm(k,k,:),N,N).*Slj+...
            Sik.*Slj.*(1-repmat(Sm(k,l,:),N,N))+Sik.*repmat(Sm(l,l,:),N,N).*Skj);

m = length(Nlisti);
Sm(Nlisti,Nlisti,:) = (Sm(Nlisti,Nlisti,:) + ...
        1./repmat((1- Sm(k,l,:)-Sm(l,k,:)+Sm(k,l,:).*Sm(l,k,:)-Sm(k,k,:).*Sm(l,l,:)),m,m).*A(Nlisti,Nlisti,:));

% Remove rows and columns k and l
S = Sm(Nlisti,Nlisti,:);
end