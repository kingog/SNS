function [ninputs noutputs ncnodes ntnodes] = getScatteringR(inputs,outputs,cnodes,tnodes,num)
% [ninputs noutputs ncnodes ntnodes] = getScatteringR(inputs,outputs,cnodes,tnodes,num)
% This function returns the combined scattering matrix of the supplied
% network. It operates recursively, shrinking the network one central node
% at a time, until all that remains is input nodes, output nodes, and
% terminated nodes.
%
% Algorithm:
% Look for special cases and escape clauses
% ELSE:
% Take first element of cnodes
% Build a new network from the nodes surrounding cnodes{1}
% Call getScattering() on the new network, get the new S, Snew
% Make new Nport object from Snew
% Reconnect the nodes surrounding cnodes{1}
% Create new network excluding cnodes{1}
% getScatteringR(new network)
%
% Copyright Oliver King, March 2010
% ogk@astro.caltech.edu
%

debug = 0;
if num == 0
    fprintf('   %d nodes remaining\n',length(cnodes))
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Break out of recursion? 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Does cnodes contain only one element, and is the forward and backwards node
% for that element the same? If so, then no reason to call the recursive
% function again. Just calculate the scattering matrix and be done.

% Another special case for breaking the recursion: if every element of
% cnodes is connected to the same two N-port objects.
% Test for this:
% Make a list of backwards and forwards objects. Add every object from each
% node to the list, unless it is already there. If the length every exceeds
% 2, quit, because we haven't met the criteria.
scon = 1;
nlist = {};
for k=1:length(cnodes)
    % Add each node object unless it is already there:
    % Forward node:
    dontAdd = 0;
    for m=1:length(nlist)
        if nlist{m} == cnodes{k}.Nf
            dontAdd = 1;
            break
        end
    end
    if dontAdd == 0
        nlist{end+1} = cnodes{k}.Nf;
    end
    if length(nlist) > 2
        scon = 0;
        break
    end
    
    % Backward node:
    dontAdd = 0;
    for m=1:length(nlist)
        if nlist{m} == cnodes{k}.Nb
            dontAdd = 1;
            break
        end
    end
    if dontAdd == 0
        nlist{end+1} = cnodes{k}.Nb;
    end
    if length(nlist) > 2
        scon = 0;
        break
    end
end

if scon == 1 && cnodes{1}.Nf ~= cnodes{1}.Nb
    [Sc,cc] = getScattering(inputs,outputs,cnodes,tnodes,num);
    inputs{1}.Nf.S = Sc;
    inputs{1}.Nf.c = cc;
    
    ninputs = inputs;
    noutputs = outputs;
    ncnodes = {};
    ntnodes = tnodes;
    
elseif length(cnodes) == 1 && cnodes{1}.Nf == cnodes{1}.Nb
    % Contains a central node connected twice to the same N-port device.
    % Using the replacement formula, calculate the new scattering matrix, 
    % connect up the elements, and return the connected network.
    Sm = getS(cnodes{1});
    cm = getC(cnodes{1});
    
    inputs{1}.Nf.S = Sm;
    inputs{1}.Nf.c = cm;
    
    ninputs = inputs;
    noutputs = outputs;
    ncnodes = {};
    ntnodes = tnodes;
    
elseif isempty(cnodes)
    ninputs = inputs;
    noutputs = outputs;
    ncnodes = newC;
    ntnodes = tnodes;
else
    % Reduce the network by one (or more) node(s)!

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Take first element of cnodes
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    cn = cnodes{1};
    if debug
        disp('Calling recursive network solver')
        cn
        cn.Nf
        cn.Nf.S
        cn.Nb
        cn.Nb.S
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Build a new network from the nodes surrounding cnodes{1}
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % inputs:
    % all nodes connected to the object in the cn reverse direction
    % outputs:
    % all nodes connected to the object in the cn forward direction
    % cnodes = {cn}
    % tnodes = {}
    inps = cn.Nb.nodes;
    % inps includes the cn node, remove it
    Pilist = [1:cn.Nb.N];
    inn = {};
    if cn.Nf ~= cn.Nb
        Pilist = Pilist(Pilist~=cn.Nbp);
    else
        Pilist = Pilist(Pilist~=cn.Nbp & Pilist~=cn.Nfp);
    end
    for k=1:length(Pilist)
        inn{k} = inps{Pilist(k)};
    end

    outs = cn.Nf.nodes;
    % outs includes the cn node, remove it
    Polist = [1:cn.Nf.N];
    ott = {};
    if cn.Nf ~= cn.Nb
        Polist = Polist(Polist~=cn.Nfp);
        for k=1:length(Polist)
            ott{k} = outs{Polist(k)};
        end
    else
        Polist = Polist(Polist~=cn.Nfp & Polist~=cn.Nbp);
        ott = {};
    end
    
    % In some topologies a node will end up in both inn and ott if it is in
    % "parallel" with cn (i.e. its backward node is the same as cn's
    % backward node, and its forward node is the same as cn's forward
    % node). Identify if this is the case now, and call the algorithm  on 
    % both simultaneously if it is.
    % How do do this? Check for duplicates in inn and ott, if they exist,
    % move them to central nodes, them resume the script.
    cnds = {cn};
    Ncnds = 1;
    
    % List of elements to remove from inn and ott
    innL = [];
    ottL = [];
    for k=1:length(inn)
        for m=1:length(ott)
            if inn{k} == ott{m}
                % Add to list of central nodes and remove from inn and ott
                Ncnds = Ncnds + 1;
                cnds{Ncnds} = inn{k};
                innL = [innL k];
                ottL = [ottL m];
            end
        end
    end
    Li = length(inn);
    Lo = length(ott);
    inn = inn(~ismember(1:Li,innL));
    ott = ott(~ismember(1:Lo,ottL));
    Pilist = Pilist(~ismember(1:Li,innL));
    Polist = Polist(~ismember(1:Lo,ottL));
    

    % Some of the items in inn are connected via their reverse node - they thus
    % won't be detected properly by the getScattering function. They
    % need to be moved to ott, unless they're already there.
    % Similarly, some of the items in ott are connected via their forward node
    % and need to be moved to inn.
    % They need to be moved to the correct position in ott. They could be
    % either cnodes, outputs nodes or terminated nodes.

    % 1: Identify misplaced items in inn and ott
    % 2: Copy them to the correct cell array
    % 3: Remove them from the incorrect cell array
    % 4: Re-order the cell arrays to keep the S matrices sane.

    if debug
        disp('    Sorting nodes')
    end

    % Identify elements of inn which are connected by their reverse node to the
    % Nport device referred to here.
    LottO = length(ott); %used later for checking ott for inappropriate elements
    No = length(ott)+1;
    kl = [];
    for k=1:length(inn)
        if ~isempty(inn{k}.Nb) 
            if inn{k}.Nb == cn.Nb
                % Copy it to ott: re-order later
                ott{No} = inn{k};
                Polist = [Polist Pilist(k)];
                No = No+1;
                % List of nodes to be removed
                kl = [kl k];
            end
        end
    end
    % Remove elements kl from inn
    inn = inn(~ismember(1:length(inn),kl));
    Pilist = Pilist(~ismember(1:length(Pilist),kl));
    

    % Check ott for inappropriate elements. These are elements connected to the
    % device by their forward node. Only cycle through the original inhabitants
    % of ott (don't consider those just added).
    No = length(inn)+1;
    kl = [];
    for k=1:LottO
        if ~isempty(ott{k}.Nf)
            if ott{k}.Nf == cn.Nf
                % Copy it to inn: re-order later
                inn{No} = ott{k};
                No = No+1;
                Pilist = [Pilist Polist(k)];
                % List of nodes to be removed
                kl = [kl k];
            end
        end
    end
    % Remove elements kl from ott
    ott = ott(~ismember(1:length(ott),kl));
    Polist = Polist(~ismember(1:length(Polist),kl));


    % Re-order the elements in ott to match their order in the outputs and
    % tnodes cells.
    pos = zeros(1,length(ott));
    for k=1:length(ott)
        % what is this elements position in outputs?
        for m=1:length(outputs)
            if ott{k}==outputs{m}
                pos(k) = m;
                break
            end
        end
        % was it in outputs? if not, search cnodes
        if pos(k) == 0
            for m=1:length(cnodes)
                if ott{k}==cnodes{m}
                    pos(k) = m+length(outputs);
                    break
                end
            end
        end
        % Found yet? if not, search tnodes
        if pos(k) == 0
            for m=1:length(tnodes)
                if ott{k}==tnodes{m}
                    pos(k) = m+length(outputs)+length(cnodes);
                    break
                end
            end
        end
    end
    % Now, element k in ott has position pos(k) in the order of precedence.
    % Re-order them if necessary:
    if ~all(sort(pos)==pos)
        ottOld = ott;
        sp = sort(pos);
        lst = 1:length(ott);
        for k=1:length(ottOld)
            ott{lst(pos(k)==sp)} = ottOld{k};
        end
    end

    % Re-order the elements in inn to match their order in the inputs and
    % cnodes cells.
    pos = zeros(1,length(inn));
    for k=1:length(inn)
        % what is this elements position in inputs?
        for m=1:length(inputs)
            if inn{k}==inputs{m}
                pos(k) = m;
                break
            end
        end
        % was it in inputs? if not, search cnodes
        if pos(k) == 0
            for m=1:length(cnodes)
                if inn{k}==cnodes{m}
                    pos(k) = m+length(inputs);
                    break
                end
            end
        end
    end
    % Now, element k in inn has position pos(k) in the order of precedence.
    % Re-order them if necessary:
    if ~all(sort(pos)==pos)
        inpsOld = inn;
        sp = sort(pos);
        lst = 1:length(inn);
        for k=1:length(inpsOld)
            inn{lst(pos(k)==sp)} = inpsOld{k};
        end
    end


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Call getScattering() on the new network, get the merged S (called Sm)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Need to handle cn specially: if forward N port is the same as backward
    % N-port do special calculation, don't call getScattering
    if debug
        disp('    Calling algorithm')
    end
    if cn.Nf == cn.Nb
        % Do special calculation to get Sm and cm.
        Sm = getS(cn);
        cm = getC(cn);
    else
        [Sm,cm] = getScattering(inn,ott,cnds,{},num);
    end
    % What are the port numbers now, not that they really matter?
    % Ports are numbered according to [inputs outputs cnodes tnodes]
    Pilist = [1:length(inn)];
    Polist = [1:length(ott)]+length(Pilist);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Make new Nport object from Sm
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    NewNP = makeNport();
    NewNP.S = Sm;
    NewNP.c = cm;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Reconnect the nodes surrounding cnodes{1}
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % The nodes connected to the reverse Nport object need to be connected to
    % this new object:
    % The list of nodes is inn and the ports they were connected to is Pilist
    if debug
        disp('    Reconnecting nodes')
    end
    for k=1:length(Pilist)
        % Keep reverse connection the same
        connectNode(inn{k},inn{k}.Nb,inn{k}.Nbp,NewNP,Pilist(k));
    end
    for k=1:length(Polist)
        % Keep forward connection the same
        connectNode(ott{k},NewNP,Polist(k),ott{k}.Nf,ott{k}.Nfp);
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Create new network excluding elements of cnds
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if length(cnds) == 1
        % simple, classical, case
        newC = {};
        for k=2:length(cnodes)
            newC{k-1} = cnodes{k};
        end
    else
        % special case where some elements were in parallel. they could be
        % anywhere in cnodes.
        cfnd = zeros(1,length(cnodes));
        for k=1:length(cnodes)
            for m=1:length(cnds)
                if cnds{m}==cnodes{k}
                    cfnd(k) = 1;
                end                    
            end
        end
        % cfnd == 1 where that element of cnodes needs to be excluded
        newC = cnodes(~cfnd);
    end

    % Call the recursive function on the newly reduced network:
    [ninputs noutputs ncnodes ntnodes] = getScatteringR(inputs,outputs,newC,tnodes,num);
end

end