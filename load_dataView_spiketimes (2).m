filenames = dir('*.txt');

disp(['Processing ', num2str(length(filenames)), ' files!']);

spiketimes = {};

for i=1:length(filenames)
    disp([newline, 'Loading file ', num2str(i), ' of ', num2str(length(filenames))]);
    
    fname = filenames(i).name;
    
    if strfind(fname, 'pressure')
        continue;
    end
    
    fid = fopen(fname);
    dat = textscan(fid, '%f%f', 'Delimiter', '\t');
    fclose(fid);
    
    fname_parts = split(fname, '_');
    % Determine time offset from file name
    t_offset = 0;
    for j=1:length(fname_parts)
        part = fname_parts(j);
        if strfind(part{:}, 't') == 1
            str_parts = split(fname_parts(j), '=');
            str_offset = strrep(str_parts(2), 'p', '.');
            t_offset = str2num(str_offset{:})*1000; % time in ms
        end
    end
    disp(['t_offset=', num2str(t_offset)]);
    
    % Determine unit ID
    unit_str = 0;
    for j=1:length(fname_parts)
        part = fname_parts(j);
        if strfind(part{:}, 'Unit') == 1
            unit_str = part{:};
        end
    end
    
    
    if isfield(spiketimes, unit_str)
        ts = spiketimes.(unit_str);
        spiketimes.(unit_str) = [ts; dat{1}+t_offset];
    else
        spiketimes.(unit_str) = dat{1}+t_offset;
    end
end