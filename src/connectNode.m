function connectNode(N,NP1,P1,NP2,P2)
% connectNode(N,NP1,P1,NP2,P2)
% This function connects the node N to Nports NP1 and NP2
% It connects the backward port of N to port P1 of NP1, and the forward
% port of N to port P2 of NP2.
%
% Copyright Oliver King, March 2010
% ogk@astro.caltech.edu
%

% Change the node properties
N.Nb = NP1;
N.Nbp = P1;
N.Nf = NP2;
N.Nfp = P2;

% Change the Nport properties
NP1.nodes{P1} = N;
NP1.N = length(NP1.nodes);
NP2.nodes{P2} = N;
NP2.N = length(NP2.nodes);