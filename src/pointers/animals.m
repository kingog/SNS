function root = animals(root)

if nargin < 1
    root = malloc;
    root.question = 'CAT';
end;

while 1
    cur = root;

    disp('Think of an animal!');
    ans = input_char('Are you ready? Y/N [Y]: ', 'YN', 'Y');
    if ans == 'n'
        return;
    end;

    while isfield(struct(cur), 'yes') && isfield(struct(cur), 'no')
        ans = input_char([cur.question, '? Y/N [Y]: '], 'YN', 'Y');
        if ans == 'y'
            cur = cur.yes;
        else
            cur = cur.no;
        end;
    end;

    animal = cur.question;
    disp(['I suppose you think of a ', animal]);
    ans = input_char('Is it true? Y/N [Y]: ', 'YN', 'Y');

    if ans == 'n'
        user_animal = upper(input_str('So, what do you think of? '));
        disp(['Enter a question distingushed ' animal ' from ' user_animal]);
        question = input_str('.. ');

        cur.question = question;
        cur.yes = malloc;
        cur.no = malloc;
        ans = input_char(['What is correct answer for ' user_animal ...
            '? Y/N [Y]: '], 'YN', 'Y');
        if ans == 'y'
            cur.yes.question = user_animal;
            cur.no.question = animal;
        else
            cur.yes.question = animal;
            cur.no.question = user_animal;
        end;
    end;
end;

function ans = input_char(prompt, list, default)
list = lower(list);
while 1
    ans = input(prompt, 's');
    if isempty(ans)
        ans = default;
    end;
    ans = lower(ans(1));
    if ~isempty(find(list == ans))
        break;
    end;
end;

function ans = input_str(prompt)
while 1
    ans = input(prompt, 's');
    if ~isempty(ans)
        return;
    end;
end;

