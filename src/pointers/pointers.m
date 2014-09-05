function pointers(varargin)

% POINTERS	Short-cut for constructing pointer objects.
%
%   POINTERS P1 P2 ... PN create pointers P1, P2, ..., PN
%
%   See also MALLOC, @POINTER\POINTER

%   Copyright 2004 Nikolai Yu. Zolotykh


  n = prod(size(varargin));

  for k = 1:n
    if ~isvarname(varargin{k})
      error('pointers:','Not a valid variable name')
    end
  end

  for k = 1:n
    evalin('caller', [varargin{k} ' = pointer']);
  end

