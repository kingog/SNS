function sub_obj = subsref(obj, s)

% SUBSREF	subsref function for pointers.

%   Copyright 2004, 2005 Nikolai Yu. Zolotykh
%   Thanks to Christoph Henninger for pointing out some bugs 
%   and to Gang Liang for a lot of suggestions.

% In the implementation of this function we can not simply call it recursively
% because some subfields of subfields ... of subfields can be pointers too.
% If we call subsref recursively MATLAB try execute builtin('subsref') 
% for this "sub-sub-...-sub-pointer" and fails with an error message.
%
% For example, if
%   a = pointer;
%   a.subfield1.subfield2 = pointer;
%   a.subfield1.subfield2.subfield3 = 'Hi';
% then
%   a, a.subfield1.subfield2 are pointers
%   a.subfield1 is a structure

n = length(s);
sub_obj = obj;

for j = 1:n
    if isa(sub_obj, 'pointer')
        if s(j).type ~= '.'
            error(['Attemt to specify subscript of a pointer with ' ...
                '''' s(j).type '''.\n' ...
                'Specify a field for a pointer object as obj.field_name']);
        end;
        field = s(j).subs;
        [sub_obj, exst] = ref(sub_obj, field);
        if exst == 0
            error(['Attemt to specify field ''' field ''' for NULL pointer']);
        end;
        if exst == -1
            error(['Specified field ''' field ''' does not exist']);
        end;
    else
        sub_obj = subsref(sub_obj, s(j));
    end;
end;
