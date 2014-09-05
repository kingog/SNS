function Stot = getScatteringHallbjorner(inputs,outputs,cnodes,tnodes,num)
% This function accepts a connected network of scattering matrices and
% works out the equivalent full scattering matrix.
%
% It implements the algorithm detailed here:
% Paul Hallbjorner (2003), Microwave and Optical Technology Letters, Vol. 38, No. 2, pp 99-102. 
%
% Copyright Oliver King, March 2010
% ogk@astro.caltech.edu
%

debug = 0;

Nin = length(inputs);
Nout = length(outputs);
Nc = length(cnodes);
Nt = length(tnodes);
N = Nin + Nout + Nc + Nt; % the total number of intersections

% Generate the intersection scattering matrix
if debug
    disp('Generating the intersection scattering matrix...')
end
X = zeros(2*N);
for k=1:2:2*N
    X(k:k+1,k:k+1) = [0 1; 1 0];
end

% Generate the C matrix
if debug
    disp('Generating the C matrix...')
end
if num == 1
    C = zeros(2*N); % a blank matrix to start with
else
    C = sym(zeros(2*N));
end
% This is the tricky bit.

% Iterate through the input nodes:
if debug
    disp('    Input nodes...')
end
for k=1:Nin
    % This node provides rows 2*k-1 and 2*k of the C matrix
    % All connections to the left are zero (ports). Hence row 2*k-1 will be
    % zero.
    % Connections to the right:
    % How many nodes does the RHS N port object have?
    Np = inputs{k}.Nf.N;
    % List of ports on inputs{k}.Nf this intersection is not connected to.
    Plist = [1:Np];
    Plist = Plist(Plist~=inputs{k}.Nfp);
    % For each of these ports, work out the intersection node number ki.
    % Then assign the appropriate element of the N port objects S matrix to
    % element C(2*k-1,ki)
    
    % This is the N port object we're connected to
    Nprt = inputs{k}.Nf;
    for p=1:length(Plist)
        % this is the intersection node we're connected to through the
        % Nport object
        nd = Nprt.nodes{Plist(p)};
        ki = findConnectionIndex(inputs,outputs,cnodes,tnodes,nd,Nprt);
        % The appropriate intersection node is node m in cnodes
        C(2*k,ki) = inputs{k}.Nf.S(inputs{k}.Nfp,Plist(p)); % Assign the value
    end
    % Now, assign the reflected element
    C(2*k,2*k) = inputs{k}.Nf.S(inputs{k}.Nfp,inputs{k}.Nfp);
end

% Iterate through the output nodes:
if debug
    disp('    Output nodes...')
end
for k=1:Nout
    % This node provides rows 2*(Nin+k)-1 and 2*(Nin+k) of the C matrix
    % All connections to the right are zero (ports). Hence row 2*(Nin+k)
    % will be zero.
    % Connections to the left:
    % How many nodes does the LHS N port object have?
    Np = outputs{k}.Nb.N;
    % List of ports on outputs{k}.Nb this intersection is not connected to.
    Plist = [1:Np];
    Plist = Plist(Plist~=outputs{k}.Nbp);
    % For each of these ports, work out the intersection node number ki.
    % Then assign the appropriate element of the N port objects S matrix to
    % element C(2*Nin+k,ki)
    % the port object we're connected to
    Nprt = outputs{k}.Nb;
    for p=1:length(Plist)
        % this is the intersection node we're connected to
        nd = Nprt.nodes{Plist(p)};
        ki = findConnectionIndex(inputs,outputs,cnodes,tnodes,nd,Nprt);
        % The appropriate intersection node is node m in cnodes
        C(2*(Nin+k)-1,ki) = outputs{k}.Nb.S(outputs{k}.Nbp,Plist(p)); % Assign the value
    end
    % Now, assign the reflected element
    C(2*(Nin+k)-1,2*(Nin+k)-1) = outputs{k}.Nb.S(outputs{k}.Nbp,outputs{k}.Nbp);
end

% Iterate through the central nodes:
if debug
    disp('    Central nodes...')
end
for k=1:Nc
    % This node provides rows 2*(Nin+Nout+k)-1 and 2*(Nin+Nout+k) of the C 
    % matrix
    % Need to fill out connections to the left: row 2*(Nin+Nout+k)-1
    % and connections to the right: row 2*(Nin+Nout+k)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Connections to the left (backwards):
    % How many nodes does the LHS N port object have?
    Np = cnodes{k}.Nb.N;
    % List of ports on cnodes{k}.Nb this intersection is not connected to.
    Plist = [1:Np];
    Plist = Plist(Plist~=cnodes{k}.Nbp);
    % For each of these ports, work out the intersection node number and
    % then the connection index ki.
    % Then assign the appropriate element of the N port objects S matrix to
    % element C(2*(Nin+Nout+k)-1,ki)
    % backwards:
    Nprt = cnodes{k}.Nb;
    for p=1:length(Plist)
        % this is the intersection node we're connected to
        nd = Nprt.nodes{Plist(p)};
        ki = findConnectionIndex(inputs,outputs,cnodes,tnodes,nd,Nprt);
        % Assign the value
        C(2*(Nin+Nout+k)-1,ki) = cnodes{k}.Nb.S(cnodes{k}.Nbp,Plist(p));
    end
    % Now, assign the reflected element
    C(2*(Nin+Nout+k)-1,2*(Nin+Nout+k)-1) = ...
        cnodes{k}.Nb.S(cnodes{k}.Nbp,cnodes{k}.Nbp);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Connections to the right:
    % How many nodes does the RHS N port object have?
    Np = cnodes{k}.Nf.N;
    % List of ports on cnodes{k}.Nf this intersection is not connected to.
    Plist = [1:Np];
    Plist = Plist(Plist~=cnodes{k}.Nfp);
    % For each of these ports, work out the intersection node number and
    % then the connection index ki.
    % Then assign the appropriate element of the N port objects S matrix to
    % element C(2*(Nin+Nout+k),ki)
    Nprt = cnodes{k}.Nf;
    for p=1:length(Plist)
        % this is the intersection node we're connected to
        nd = Nprt.nodes{Plist(p)};
        ki = findConnectionIndex(inputs,outputs,cnodes,tnodes,nd,Nprt);
        % Assign the value
        C(2*(Nin+Nout+k),ki) = cnodes{k}.Nf.S(cnodes{k}.Nfp,Plist(p));
    end
    % Now, assign the reflected element
    C(2*(Nin+Nout+k),2*(Nin+Nout+k)) = ...
        cnodes{k}.Nf.S(cnodes{k}.Nfp,cnodes{k}.Nfp);
end

% Iterate through the terminated nodes:
if debug
    disp('    Terminated nodes...')
end
for k=1:Nt
    % This node provides rows 2*(Nin+Nout+Nc+k)-1 and 2*(Nin+Nout+Nc+k) of 
    % the C matrix
    % All connections to the right are zero (terminated). Hence row 
    % 2*(Nin+Nout+Nc+k) will be zero.
    % Connections to the left:
    % How many nodes does the LHS N port object have?
    Np = tnodes{k}.Nb.N;
    % List of ports on tnodes{k}.Nb this intersection is not connected to.
    Plist = [1:Np];
    Plist = Plist(Plist~=tnodes{k}.Nbp);
    % For each of these ports, work out the intersection node number ki.
    % Then assign the appropriate element of the N port objects S matrix to
    % element C(2*(Nin+Nout+Nc+k)-1,ki)
    Nprt = tnodes{k}.Nb;
    for p=1:length(Plist)
        % this is the intersection node we're connected to
        nd = Nprt.nodes{Plist(p)};
        ki = findConnectionIndex(inputs,outputs,cnodes,tnodes,nd,Nprt);
        % The appropriate intersection node is node m in cnodes
        C(2*(Nin+Nout+Nc+k)-1,ki) = ...
            tnodes{k}.Nb.S(tnodes{k}.Nbp,Plist(p)); % Assign the value
    end
    % Now, assign the reflected element
    C(2*(Nin+Nout+Nc+k)-1,2*(Nin+Nout+Nc+k)-1) = ...
        tnodes{k}.Nb.S(tnodes{k}.Nbp,tnodes{k}.Nbp);
end


% Thus the full scattering matrix is:
if debug
    disp('Calculating scattering matrix...')
end
S = X*inv(eye(2*N)-C*X);

if debug
    disp('Selecting appropriate rows and columns...')
end
% Select only the rows and columns that correspond to input and output
% intersection nodes:
sel = [[1:Nin]*2-1 2*Nin+[1:Nout]*2]; % left for inputs, right for outputs
Stot = S(sel,sel);
end

function ki = findConnectionIndex(inputs,outputs,cnodes,tnodes,nd,Np)
% This function finds the connection index of the side of node nd which is
% connected to Nport device Np.
% The connected index will be given by 2*m-1 if it is a backwards (left)
% connection, 2*m if it is a forwards (right) connection. m is it's
% position in the vector [inputs outpus cnodes tnodes].
ki = 0;
% check central nodes:
for m=1:length(cnodes)
    if nd == cnodes{m}
        % is it on the backwards or forwards side of the node?
        if nd.Nf == Np
            % forwards side
            ki = 2*(length(inputs)+length(outputs)+m);
        else
            % backwards side
            ki = 2*(length(inputs)+length(outputs)+m)-1;
        end
    end
end
if ki == 0
    % not in the central nodes. check the inputs
    for m=1:length(inputs)
        if nd == inputs{m}
            % Always the forwards connection of an input node
            ki = 2*m;
            break
        end
    end
end
if ki == 0
    % not in the central or input nodes. check the outputs
    for m=1:length(outputs)
        if nd == outputs{m}
            % Always the backwards connection of an output node
            ki = 2*(length(inputs)+m)-1;
            break
        end
    end
end
if ki == 0
    % not in the central, input or output nodes. check the terminated nodes
    for m=1:length(tnodes)
        if nd == tnodes{m}
            % Always the backwards connection of a terminated node
            ki = 2*(length(inputs)+length(outputs)+length(cnodes)+m)-1;
            break
        end
    end
end

end