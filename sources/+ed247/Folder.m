classdef (ConstructOnLoad) Folder
    % FOLDER Enumerate the ED247 folders
    %
    % Copyright 2020 The MathWorks, Inc.
    %
    
    enumeration
        
        ADAPTER         ({'c_sources'})
        DEMOS           ({'doc','examples'})
        DOC             ({'doc','html'})
        LIBRARY         ({'libraries','ed247'})
        ROOT            ({''})
        SFUN_SOURCES    ({'libraries','ed247','sources'})
        WORK            ({'work'})
        
    end
        
    %% IMMUTABLE PROPERTIES
    properties (SetAccess = immutable, GetAccess = public)
        Path
    end
    
    %% CONSTRUCTOR
    methods
        
        function obj = Folder(subfolders)
            
            %rootdir = fileparts(fileparts(fileparts(fileparts(mfilename('fullpath')))));
            rootdir = regexprep(which('lib_ed247'),'libraries.*','');
            obj.Path = fullfile(rootdir,subfolders{:});
            
        end
        
    end
        
end