function [pathstr] = m_local_init_m()
    mainFile = mfilename('fullpath');
    [pathstr,~,~] = fileparts(mainFile);
    pathstr = strrep(pathstr, "/PipelineTesting", "");
    addpath(pathstr); % Set Path for utils functions
    pathstr = m_init_m; % call init from main path -> set all path
    addpath(pathstr); % Set again since m_init_m zeros any variable
end