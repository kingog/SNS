function display(p)

% DISPLAY Display function for pointers.

%   Copyright 2004 Nikolai Yu. Zolotykh


  disp(' ');
  disp([inputname(1),' = (pointer)']);
  disp(' ');
  if (p == 0)
    disp('  NULL');
    disp(' ');
  else
    disp(struct(p));
  end;
