function [Sf,cf] = getScattering(inputs,outputs,cnodes,tnodes,num)
% [S,c] = getScattering(inputs,outputs,cnodes,tnodes,num)
% This function works out the equivalent scattering matrix for the network
% defined by inputs, outputs, cnodes and tnodes. It also performs the noise
% propagation.
%
% If num = 0 use symbolic algebra, else perform numerical calculations.
%
% Copyright Oliver King, March 2010
% ogk@astro.caltech.edu
%

% Flag to enable debug mode. 0 == no output, 1 == print debug info.
debug = 0;

Ni = length(inputs);
No = length(outputs);
Nt = length(tnodes);
Nc = length(cnodes);
N = Ni+No+Nt+2*Nc; % equivalent to adding the sizes of all the Nport devices

if debug
    disp('Assigning full scattering matrix...')
end
M = size(inputs{1}.Nf.S,3);
S = zeros(N,N,M);
c = sym(zeros(N,1,M));
if num == 0
    S = sym(S);
end

% ------------------------------------------------------------------------
% Interconnect (node) numbering, and correspondance to numbering of S:
% ------------------------------------------------------------------------
% Input nodes are numbered 1 to Ni, and correspond to matrix elements 1 to
% Ni.
% Output nodes are numbered Ni+1 to Ni+No, and correspond to matrix 
% elements Ni+1 to Ni+No.
% Terminated nodes are numbered Ni+No+1 to Ni+No+Nt, and correspond to
% matrix elements Ni+No+1 to Ni+No+Nt.
% Central nodes are numbered Ni+No+Nt+1 to Ni+No+Nt+Nc. Central node number
% n will have interconnect number Ni+No+Nt+n, and will correspond to matrix
% elements k=Ni+No+Nt+2*n-1 (backward) and l=Ni+No+Nt+2*n (forward)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Perform initial population of S and c
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Assign the elements of the Nport S matrices to the full S matrix.
if debug
    disp('Performing initial assignment of S')
    disp('     Input nodes...')
end

% Cycle through input nodes
for n=1:Ni
    % Need to know what other interconnect numbers this node is connected
    % to
    if debug
        fprintf('             Node %d of %d\n',n,Ni)
    end
    % How many other ports does the connected N port device have?
    Np = inputs{n}.Nf.N;
    % What are the port numbers that they're connected to?
    Plist = [1:Np];
    Plist = Plist(Plist~=inputs{n}.Nfp);

    % This is the N port object we're connected to
    Nprt = inputs{n}.Nf;
    for p=1:length(Plist)
        % this is the intersection node we're connected to through the
        % Nport object
        nd = Nprt.nodes{Plist(p)};
        % This is the matrix element number of the other side
        ki = findConnectionIndex(inputs,outputs,cnodes,tnodes,nd,Nprt);
        
        % Update the matrix element
        S(n,ki,:) = inputs{n}.Nf.S(inputs{n}.Nfp,Plist(p),:);
 
    end
    % Now, assign the reflected element
    S(n,n,:) = inputs{n}.Nf.S(inputs{n}.Nfp,inputs{n}.Nfp,:);
    % Assign the elements of the c vector
    c(n,:,:) = inputs{n}.Nf.c(inputs{n}.Nfp,:,:);
end

if debug
    disp('     Output nodes...')
end
% Cycle through output nodes
for n=1:No
    % Need to know what other interconnect numbers this node is connected
    % to
    if debug
        fprintf('             Node %d of %d\n',n,No)
    end
    
    % How many other ports does the connected N port device have?
    Np = outputs{n}.Nb.N;
    % What are the port numbers that they're connected to?
    Plist = [1:Np];
    Plist = Plist(Plist~=outputs{n}.Nbp);

    % This is the N port object we're connected to
    Nprt = outputs{n}.Nb;
    for p=1:length(Plist)
        % this is the intersection node we're connected to through the
        % Nport object
        nd = Nprt.nodes{Plist(p)};
        % This is the matrix element number of the other side
        ki = findConnectionIndex(inputs,outputs,cnodes,tnodes,nd,Nprt);
        
        % Update the matrix element
        S(Ni+n,ki,:) = outputs{n}.Nb.S(outputs{n}.Nbp,Plist(p),:);
    end
    % Now, assign the reflected element
    S(Ni+n,Ni+n,:) = outputs{n}.Nb.S(outputs{n}.Nbp,outputs{n}.Nbp,:);
    % Assign the elements of the c vector
    c(Ni+n,:,:) = outputs{n}.Nb.c(outputs{n}.Nbp,:,:);
end

if debug
    disp('     Terminated nodes...')
end
% Cycle through terminated nodes
for n=1:Nt
    % Need to know what other interconnect numbers this node is connected
    % to
    if debug
        fprintf('             Node %d of %d\n',n,Nt)
    end
    % How many other ports does the connected N port device have?
    Np = tnodes{n}.Nb.N;
    % What are the port numbers that they're connected to?
    Plist = [1:Np];
    Plist = Plist(Plist~=tnodes{n}.Nbp);

    % This is the N port object we're connected to
    Nprt = tnodes{n}.Nb;
    for p=1:length(Plist)
        % this is the intersection node we're connected to through the
        % Nport object
        nd = Nprt.nodes{Plist(p)};
        % This is the matrix element number of the other side
        ki = findConnectionIndex(inputs,outputs,cnodes,tnodes,nd,Nprt);
        
        % Update the matrix element
        S(Ni+No+n,ki,:) = tnodes{n}.Nb.S(tnodes{n}.Nbp,Plist(p),:);
    end
    % Now, assign the reflected element
    S(Ni+No+n,Ni+No+n,:) = tnodes{n}.Nb.S(tnodes{n}.Nbp,tnodes{n}.Nbp,:);
    % Assign the elements of the c vector
    c(Ni+No+n,:,:) = tnodes{n}.Nb.c(tnodes{n}.Nbp,:,:);
end

if debug
    disp('     Central nodes...')
end
% Cycle through central nodes
for n=1:Nc
    % Need to know what other interconnect numbers this node is connected
    % to
    if debug
        fprintf('             Node %d of %d\n',n,Nc)
        fprintf('             Forward Nport S is:')
        cnodes{n}.Nf.S
        fprintf('             Forward Nport N is:')
        cnodes{n}.Nf.N
        fprintf('             Backward Nport S is:')
        cnodes{n}.Nb.S
        fprintf('             Backward Nport N is:')
        cnodes{n}.Nb.N
    end
    %%%%%%%%%%%%%%%%%%%%%%%%
    % Backwards first
    %%%%%%%%%%%%%%%%%%%%%%%%
    
    % How many other ports does the connected N port device have?
    Np = cnodes{n}.Nb.N;
    % What are the port numbers that they're connected to?
    Plist = [1:Np];
    Plist = Plist(Plist~=cnodes{n}.Nbp);

    % This is the N port object we're connected to
    Nprt = cnodes{n}.Nb;
    for p=1:length(Plist)
        % this is the intersection node we're connected to through the
        % Nport object
        nd = Nprt.nodes{Plist(p)};
        % This is the matrix element number of the other side
        ki = findConnectionIndex(inputs,outputs,cnodes,tnodes,nd,Nprt);
        
        % Update the matrix element
        S(Ni+No+Nt+2*n-1,ki,:) = cnodes{n}.Nb.S(cnodes{n}.Nbp,Plist(p),:);
    end
    % Now, assign the reflected element
    S(Ni+No+Nt+2*n-1,Ni+No+Nt+2*n-1,:) = cnodes{n}.Nb.S(cnodes{n}.Nbp,cnodes{n}.Nbp,:);
    % Assign the elements of the c vector
    c(Ni+No+Nt+2*n-1,:,:) = cnodes{n}.Nb.c(cnodes{n}.Nbp,:,:);
    
    %%%%%%%%%%%%%%%%%%%%%%%%
    % Now forwards
    %%%%%%%%%%%%%%%%%%%%%%%%
    
    % How many other ports does the connected N port device have?
    Np = cnodes{n}.Nf.N;
    % What are the port numbers that they're connected to?
    Plist = [1:Np];
    Plist = Plist(Plist~=cnodes{n}.Nfp);

    % This is the N port object we're connected to
    Nprt = cnodes{n}.Nf;
    for p=1:length(Plist)
        % this is the intersection node we're connected to through the
        % Nport object
        nd = Nprt.nodes{Plist(p)};
        % This is the matrix element number of the other side
        ki = findConnectionIndex(inputs,outputs,cnodes,tnodes,nd,Nprt);
        
        % Update the matrix element
        S(Ni+No+Nt+2*n,ki,:) = cnodes{n}.Nf.S(cnodes{n}.Nfp,Plist(p),:);
    end
    % Now, assign the reflected element
    S(Ni+No+Nt+2*n,Ni+No+Nt+2*n,:) = cnodes{n}.Nf.S(cnodes{n}.Nfp,cnodes{n}.Nfp,:);
    % Assign the elements of the c vector
    c(Ni+No+Nt+2*n,:,:) = cnodes{n}.Nf.c(cnodes{n}.Nfp,:,:);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Update S and c iteratively
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Cycle through the central nodes.
% Each central node has matrix elements k,l
% Update each element of S (except k and l) according to the formula.
% Update each element of the vector c appropriately.
%
Nlist = 1:N;
if debug
    disp('Performing iterative update of S elements...')
    disp('Initial S:')
    S
    
end
for n=1:Nc
    if debug
        fprintf('    Node %d of %d\n',n,Nc)
    end
    % Backwards direction has number k, forwards has l
    k = Ni+No+Nt+2*n-1;
    l = Ni+No+Nt+2*n;
    
    % The elements other than k and l, which we'll need to iterate through.
    Nlisti = Nlist(Nlist ~= k & Nlist ~= l);
    
    if debug
        tic
    end
    Sil = repmat(S(:,l,:),[1,N,1]);
    Sik = repmat(S(:,k,:),[1,N,1]);
    Skj = repmat(S(k,:,:),[N,1,1]);
    Slj = repmat(S(l,:,:),[N,1,1]);
    
    A = (Sil.*Skj.*(1-repmat(S(l,k,:),N,N))+Sil.*repmat(S(k,k,:),N,N).*Slj+...
                Sik.*Slj.*(1-repmat(S(k,l,:),N,N))+Sik.*repmat(S(l,l,:),N,N).*Skj);
    
    m = length(Nlisti);
    S(Nlisti,Nlisti,:) = (S(Nlisti,Nlisti,:) + ...
        1./repmat((1- S(k,l,:)-S(l,k,:)+S(k,l,:).*S(l,k,:)-S(k,k,:).*S(l,l,:)),m,m).*A(Nlisti,Nlisti,:));
    
    for i=Nlisti
        % update every element except k and l
        c(i,:,:) = c(i,:,:) + ((S(i,l,:).*S(k,k,:)+S(i,k,:).*(1-S(k,l,:))).*c(l,:,:)+...
            (S(i,k,:).*S(l,l,:)+S(i,l,:).*(1-S(l,k,:))).*c(k,:,:))./...
            ((1-S(k,l,:)).*(1-S(l,k,:))-S(k,k,:).*S(l,l,:));
    end
    
    if debug
        t = toc;
        fprintf('    Time was %f per iteration\n',t/80)
        fprintf('    S matrix is now:\n')
        S
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Select appropriate elements of S and c
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Need to select the matrix element numbers which correspond to the input
% and output elements.
if debug
    disp('Selecting input and output columns...')
end
% Easy peasy
sel = [1:Ni+No];
Sf = S(sel,sel,:);
cf = c(sel,:,:);
end

function ki = findConnectionIndex(inputs,outputs,cnodes,tnodes,nd,Np)
% This function finds the matrix element number of the side of node nd 
% which is connected to Nport device Np.
% The matrix element number will be:
% m if nd is in inputs
% Ni+m if nd is in outputs
% Ni+No+m if nd is in tnodes
% Ni+No+Nt+2*m-1 if nd is in cnodes, and a backwards connection
% Ni+No+Nt+2*m if nd is in cnodes, and a forwards connection
% m is the node's position in its vector (inputs, outputs, cnodes, tnodes).
Ni = length(inputs);
No = length(outputs);
Nt = length(tnodes);
Nc = length(cnodes);

ki = 0;
% check central nodes:
for m=1:Nc
    if nd == cnodes{m}
        % is it on the backwards or forwards side of the node?
        if nd.Nf == Np
            % forwards side
            ki = Ni+No+Nt+2*m;
            break
        else
            % backwards side
            ki = Ni+No+Nt+2*m-1;
            break
        end
    end
end
if ki == 0
    % not in the central nodes. check the inputs
    for m=1:Ni
        if nd == inputs{m}
            ki = m;
            break
        end
    end
end
if ki == 0
    % not in the central or input nodes. check the outputs
    for m=1:No
        if nd == outputs{m}
            ki = Ni+m;
            break
        end
    end
end
if ki == 0
    % not in the central, input or output nodes. check the terminated nodes
    for m=1:Nt
        if nd == tnodes{m}
            ki = Ni+No+m;
            break
        end
    end
end

end