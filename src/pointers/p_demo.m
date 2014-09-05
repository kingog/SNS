function p_demo

% P_DEMO		Demo program for pointer library.

%   Copyright 2004 Nikolai Yu. Zolotykh

  ar = {'Isaac Newton', 'Carl F. Gauss', 'Evariste Galois', 'Blaise Pascal', ...
    'Georg F. L. Ph. Cantor', 'Nikolai I. Lobachevski'};
  n = length(ar);

  prev = 0;
  cur = 0;

  for j = 1:n
    cur = malloc;
    cur.data = ar{j};
    cur.next = prev;
    prev = cur;
  end;

  list = cur;
   
  while (cur ~= 0)
    disp(cur.data);
    cur = cur.next;
  end;

  cur = list;

  while (cur ~= 0)
    prev = cur;
    cur = cur.next;
    free(prev);
  end;

  