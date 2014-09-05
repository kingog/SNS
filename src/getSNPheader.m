function [UNITS,form,hlines] = getSNPheader(fname)
% [header,hlines] = getSNPheader(fname)
% Get the UNITS to convert to GHz, the format (form), and the number of
% header lines for the SNP file in fname

% How many hlines?
fid = fopen(fname,'r');
flag = 1;
hlines = 0;
while flag
    tline = fgetl(fid);
    if tline(1) ~= '!' && tline(1) ~= '#'
        flag = 0;
    else
        hlines = hlines + 1;
    end
end
fclose(fid);

% Import the file
d = importdata(fname, ' ', hlines);

% Get the header information:
for k=1:length(d.textdata)
    if d.textdata{k}(1) == '#'
        % Get the units etc.:
        tline = d.textdata{k};
        % Break it up by spaces:
        a = strsplit(' ',tline);
        p = 1;
        for m=1:length(a)
            if ~isempty(a{m})
                info{p} = a{m};
                p = p+1;
            end
        end
        % Now, set the flags which determine the behavior of the rest of
        % the circuit:
        switch info{2}
            case 'HZ'
                UNITS = 10^9;
            case 'KHZ'
                UNITS = 10^6;
            case 'MHZ'
                UNITS = 10^3;
            case 'GHZ'
                UNITS = 10^0;
            otherwise
                UNITS = 1;
                disp('ERROR INTERPRETING UNIT TYPE')
        end
        form = info{4};
    end
end