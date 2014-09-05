function N = makeNode(varargin)
% Constructs a node pointer object
% N = makeNode(Pf,Pb,Of,Ob) creates a node object with the following
% properties:
%   * Pf -> Power in the forward direction
%   * Pb -> Power in the backward direction
%   * Nf -> Object port connected to the forward output
%   * Nb -> Object port connected to the backward output
%   * Nfp -> Port on Nf that node is connected to
%   * Nbp -> Port on Nb that node is connected to
%
% Usually called without any arguments:
% N = makeNode();
% Connections and assignments are made later.
%
% Copyright Oliver King, March 2010
% ogk@astro.caltech.edu
%

N = pointer;
switch nargin
    case 0
        % If no input arguments, create a default object
        N.Pf = 0;
        N.Pb = 0;
        N.Nf = [];
        N.Nb = [];
        N.Nfp = [];
        N.Nbp = [];
    case 6
        % Fully specified object
        N.Pf = varargin{1};
        N.Pb = varargin{2};
        N.Nf = varargin{3};
        N.Nfp = varargin{4};
        N.Nb = varargin{5};
        N.Nbp = varargin{6};
    otherwise
        error('Incorrect number of node parameters!')
end