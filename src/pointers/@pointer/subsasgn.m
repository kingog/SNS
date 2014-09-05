function obj = subsasgn(obj, s, b)

% SUBSASGN	subsasgn function for pointers.

%   Copyright 2004, 2005 Nikolai Yu. Zolotykh
%   Thanks to Gang Liang for a lot of suggestions

obj = do_subsasgn(obj, s, b);
% We use subfunction do_subsasgn instead of direct using subsasgn 
% recursively to guarantee that just do_subsasgn is called:
% in subsasgn(obj, s, b) if obj or b is pointer then MATLAB calls subsasgn(...)
% recursively, otherwise MATLAB calls builtin('subsasgn', ...)

function obj = do_subsasgn(obj, s, b)

field1 = s(1).subs;
type1 = s(1).type;

if length(s) == 1
    if isa(obj, 'pointer')
        if type1 ~= '.'
            error(['Attemt to specify subscript of a pointer with ' ...
                '''' type1 '''.\n' ...
                'Specify a field for a pointer object as obj.field_name']);
        end;
        obj = assgn(obj, field1, b);
    else
        obj = builtin('subsasgn', obj, s(1), b);
    end;
else
    if isa(obj, 'pointer')
        if type1 ~= '.'
            error(['Attemt to specify subscript of a pointer with ' ...
                '''' type1 '''.\n' ...
                'Specify a field for a pointer object as obj.field_name']);
        end;
        [sub_obj, exst] = ref(obj, field1);
        if exst == 1
            sub_obj = do_subsasgn(sub_obj, s(2:end), b);
        else
            % If pointer is NULL or field does not exist we create new field:
            sub_obj = [];
            sub_obj = builtin('subsasgn', sub_obj, s(2:end), b);
        end;
        obj = assgn(obj, field1, sub_obj);
    else
        try
            sub_obj = subsref(obj, s(1));
        catch
            sub_obj = [];
        end
        sub_obj = do_subsasgn(sub_obj, s(2:end), b);
        obj = builtin('subsasgn', obj, s(1), sub_obj);
    end;
end;
