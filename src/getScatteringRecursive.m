function [S,c] = getScatteringRecursive(inputs,outputs,cnodes,tnodes,num)
% [S,c] = getScatteringRecursive(inputs,outputs,cnodes,tnodes,num)
% A wrapper function for the recursive network reducing function.
%
% inputs, outputs, cnodes, and tnodes are cells of node objects. cnodes =
% central nodes (removed by algorithm), tnodes = terminated nodes (removed
% by algorithm). inputs and outputs are self-explanatory.
%
% Eventually, should operate on a copy of the network, because this
% function modifies the items in the network.
%
% Note: this function defines a symbolic variable Tt - the temperature of
% the terminated nodes - and includes it in c, if there are terminated
% nodes.
%
% Copyright Oliver King, March 2010
% ogk@astro.caltech.edu
%


% First, remove the terminated nodes from the network by modifying the
% S-matrices they're connected to.
for k=1:length(tnodes)
    tn = tnodes{k};
    inps = tn.Nb.nodes;
    % inps includes the tn node, remove it
    Pilist = [1:tn.Nb.N];
    Pilist = Pilist(Pilist~=tn.Nbp);
    for m=1:length(Pilist)
        inn{m} = inps{Pilist(m)};
    end
    % Some elements of inn are connected to tn via their reverse nodes.
    % Move them to an outputs cell array
    No = 1;
    kl = [];
    ott = {};
    for m=1:length(inn)
        if ~isempty(inn{m}.Nb) 
            if inn{m}.Nb == tn.Nb
                % Copy it to ott: re-order later
                ott{No} = inn{m};
                No = No+1;
                % List of nodes to be removed
                kl = [kl m];
            end
        end
    end
    % Remove from inn
    inps = {};
    ni = 1;
    for m=1:length(inn)
        if ~any(kl==m)
            inps{ni} = inn{m};
            ni = ni+1;
        end
    end
    
    % inps and ott contain the inputs and outputs to the tnode.
    % What are their port numbers?
    innN = [];
    for m=1:length(inps)
        innN = [innN inps{m}.Nfp];
    end
    ottN = [];
    for m=1:length(ott)
        ottN = [ottN ott{m}.Nbp];
    end
    
    Sm = tn.Nb.S;
    cm = tn.Nb.c;
    % Remove the terminated node from the S matrix
    Nt = tn.Nbp;
    Nlist = 1:size(Sm,1);
    Nlist = Nlist(Nlist~=Nt);
    
%     % Situation for the c vector is slightly more complicated, because
%     % terminations still add noise. Update formula according to pg 86 of
%     % lab book 4: ci^new = ci + Sik*sqrt(k_B*T) where port k is terminated.
%     syms kb Tt real
%     cm = cm + Sm(:,Nt,:)*sqrt(kb*Tt); % need to-be-removed column of Sm at this point

    % If you want terminations to add noise, declare them as 1 port devices
    % with a noise correlation matrix
    cm = cm(Nlist,:,:);
    Sm = Sm(Nlist,Nlist,:); % now safe to remove offending rows and columns of Sm
    
    % What are the other connections' new node numbers?
    innN(innN>Nt) = innN(innN>Nt)-1;
    ottN(ottN>Nt) = ottN(ottN>Nt)-1;
    
    % Make a node:
    NewNP = makeNport();
    NewNP.S = Sm;
    NewNP.c = cm;
    
    % Connect the inputs and outputs to the new N-port device.
    for m=1:length(inps)
        connectNode(inps{m},inps{m}.Nb,inps{m}.Nbp,NewNP,innN(m));
    end
    for m=1:length(ott)
        connectNode(ott{m},NewNP,ottN(m),ott{m}.Nf,ott{m}.Nfp);
    end
end

[ips,ops,cns,tns] = getScatteringR(inputs,outputs,cnodes,{},num);
S = ips{1}.Nf.S;
c = ips{1}.Nf.c;

end