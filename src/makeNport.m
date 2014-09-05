function P = makeNport(varargin)
% Constructs an Nport pointer object
% P = makeNport(Nports,S,f,varargin) creates an nport object with the following
% properties:
%   * N -> number of ports
%   * S -> S matrix for the N port device
%   * c -> c vector (noise) for the N-port device
%   * f -> frequency points at which S is defined
%   * varargin -> nodes to which the Nports are connected
%
% Usually called without any arguments:
% P = makeNport();
% Matrices and connections are assigned later.
%
% Copyright Oliver King, March 2010
% ogk@astro.caltech.edu
%

P = pointer();
switch nargin
    case 0
        % No inputs - create default object
        P.N = 2;
        P.S = [0 0;0 0];
        P.c = [0;0];
        P.f = 0;
        P.nodes = {};
    case 2
        error('Incorrect number of inputs for nport class! 2 is not enough')
    case 3
        error('Incorrect number of inputs for nport class! 3 is not enough')
    case 4
        error('Incorrect number of inputs for nport class! 4 is not enough')
    otherwise
        P.N = varargin{1};
        P.S = varargin{2};
        P.c = varargin{3};
        P.f = varargin{4};
        P.nodes = {varargin{5:nargin}};
end