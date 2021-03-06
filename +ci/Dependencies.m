classdef Dependencies < matlab.mixin.SetGet
   
    %% CONSTANT
    properties (Constant)
        ARTIFACT_JOB = "compile";
    end
    
    %% DEPENDENT PROPERTIES
    properties (Dependent)
        HostLibraryURL
        TargetLibraryURL
    end
    
    %% OPTIONS
    properties
        BranchName      (1,1)   string
        Host            (1,1)   string
        ProjectID       (1,1)   string
        ServerURL       (1,1)   string
        Suffix          (1,1)   string
        Target          (1,1)   string
        Token           (1,1)   string
    end
    
    %% IMMUTABLE PROPERTIES
    properties (SetAccess = immutable, GetAccess = private)
        
        ed247folder_            (1,1)   string
        qnxfolder_              (1,1)   string
        rootfolder_             (1,1)   string
        temporaryfolder_        (1,1)   string
        
        hostarchive_            (1,1)   string
        targetarchive_          (1,1)   string
        
    end
    
    %% CONSTRUCTOR
    methods
       
        function obj = Dependencies(rootfolder, ed247folder, qnxfolder, temporaryfolder, varargin)
                        
            obj.ed247folder_        = ed247folder;
            obj.qnxfolder_          = qnxfolder;
            
            obj.rootfolder_         = rootfolder;
            obj.temporaryfolder_    = temporaryfolder;
            
            obj.hostarchive_        = fullfile(obj.temporaryfolder_, "host.zip");
            obj.targetarchive_      = fullfile(obj.temporaryfolder_, "target.zip");
            
            if ~isempty(varargin)
                set(obj, varargin{:})
            end
            
            if ~isfolder(obj.temporaryfolder_)
                mkdir(obj.temporaryfolder_)
            end
            
        end
        
        function delete(obj)
            if isfolder(obj.temporaryfolder_)
                rmdir(obj.temporaryfolder_,"s")
            end
        end
        
    end
    
    %% ACCESSORS
    methods
               
        function hostlibraryurl = get.HostLibraryURL(obj)
            % Reference : https://docs.gitlab.com/ee/api/job_artifacts.html
            hostlibraryurl = obj.ServerURL + "/api/v4/projects/" + ...
                obj.ProjectID + "/jobs/artifacts/" + obj.BranchName + ...
                "/download?job=" + obj.Host + ":" + obj.ARTIFACT_JOB;
            if obj.Suffix ~= ""
                hostlibraryurl = hostlibraryurl + ":" + obj.Suffix;
            end
        end
       
        function targetlibraryurl = get.TargetLibraryURL(obj)
            % Reference : https://docs.gitlab.com/ee/api/job_artifacts.html
            targetlibraryurl = obj.ServerURL + "/api/v4/projects/" + obj.ProjectID + "/jobs/artifacts/" + obj.BranchName + "/download?job=" + obj.Target + ":" + obj.ARTIFACT_JOB;
        end
        
    end
    
    %% PUBLIC METHODS
    methods
        
        function cleanup(obj)
            
            clear("mex") %#ok<CLMEX>
                        
            if isfolder(obj.ed247folder_)
                obj.print("Delete ED247 folder '%s' ...", obj.ed247folder_)
                rmdir(obj.ed247folder_,"s")
                obj.print("\b Done")
            end
            
            if isfolder(obj.qnxfolder_)
                obj.print("Delete QNX folder '%s' ...", obj.ed247folder_)
                rmdir(obj.qnxfolder_,"s")
                obj.print("\b Done")
            end
            
        end
        
        function download(obj)
                        
            opts = weboptions("HeaderFields",["PRIVATE-TOKEN",obj.Token],"ContentType","binary");
                        
            try
                
                destfolder = fileparts(obj.hostarchive_);
                if ~isfolder(destfolder)
                    mkdir(destfolder)
                end
                
                obj.print("Download Host archive at URL '%s' to '%s' ...", obj.HostLibraryURL, obj.hostarchive_)
                websave(obj.hostarchive_,obj.HostLibraryURL,opts);
                obj.print("\b Done")
            
            catch me
                
                if me.identifier == "MATLAB:webservices:HTTP404StatusCodeError"
                    obj.warning("ci:Prepare:unableToAccessURL", ...
                        "Cannot download Host archive (%s) : %s", me.identifier, me.message)
                else
                    obj.rethrow(me)
                end
                
            end
                    
            try
                
                destfolder = fileparts(obj.targetarchive_);
                if ~isfolder(destfolder)
                    mkdir(destfolder)
                end
                
                obj.print("Download Target archive at URL '%s' to '%s' ...", obj.TargetLibraryURL, obj.targetarchive_)
                websave(obj.targetarchive_,obj.TargetLibraryURL,opts);
                obj.print("\b Done")
                
            catch me
                
                if me.identifier == "MATLAB:webservices:HTTP404StatusCodeError"
                    obj.warning("ci:Prepare:unableToAccessURL", ...
                        "Cannot download Target archive (%s) : %s", me.identifier, me.message)
                else
                    obj.rethrow(me)
                end
                
            end
            
        end
        
        function install(obj)
            
            obj.assert(exist(obj.hostarchive_, "file") == 2, ...
                "ci:Prepare:NoArchive", "Host archive (%s) does not exist, make sure to download it before installing", ...
                obj.hostarchive_)
            obj.assert(exist(obj.targetarchive_, "file") == 2, ...
                "ci:Prepare:NoArchive", "Target archive (%s) does not exist, make sure to download it before installing", ...
                obj.targetarchive_)
            
            currentfolder = pwd;
            cd(obj.temporaryfolder_)
            pushd = onCleanup(@() cd(currentfolder));
            
            obj.print("Unzip host archive to temporary folder")
            unzip(obj.hostarchive_)
            obj.print("Unzip target archive to temporary folder")
            unzip(obj.targetarchive_)
            
            if ~isfolder(obj.ed247folder_)
                obj.print("Create folder '%s'", obj.ed247folder_)
                mkdir(obj.ed247folder_)
            end
            
            %
            % Copy host library (Linux or Windows) to dependency folder
            %
            hostlibraryfiles   = fullfile(obj.temporaryfolder_, "_install");
            obj.print("Copy ED247 host library into '%s'", obj.ed247folder_)
            copyfile(hostlibraryfiles,obj.ed247folder_)
            
            %
            % Copy target library (QNX) to dependency folder
            %
            if ~isempty(obj.qnxfolder_) && obj.qnxfolder_ ~= ""
                targetlibraryfiles      = fullfile(obj.temporaryfolder_, "_install_qnx");
                if ~isfolder(obj.qnxfolder_)
                    obj.print("Create folder '%s'", obj.qnxfolder_)
                    mkdir(obj.qnxfolder_)
                end
                obj.print("Copy ED247 target library into '%s'", obj.qnxfolder_)
                copyfile(fullfile(targetlibraryfiles, "*.*"), obj.qnxfolder_)
            else
                obj.print("Skip installation of target library")
            end
                        
        end
        
        function configure(obj)
           
            obj.print("Update configuration")
            config = ed247.Configuration.default();
            
            obj.print("\t- ED247 folder : '%s'", obj.ed247folder_)
            config.ED247    = obj.ed247folder_;
                        
            obj.print("\t- QNX folder : '%s'", obj.qnxfolder_)
            config.QNXLib   = obj.qnxfolder_;
            
            obj.print("Save configuration")
            save(config)
            
        end
        
    end
    
    %% HELPER METHODS (PROTECTED)
    methods (Access = protected)
        
        function assert(obj,varargin) %#ok<INUSL>
            assert(varargin{:})
        end
        
        function error(obj,varargin) %#ok<INUSL>
            error(varargin{:})
        end
        
        function warning(obj,varargin) %#ok<INUSL>
            warning(varargin{:})
        end
        
        function print(obj,varargin) %#ok<INUSL>
            fprintf(1,varargin{1} + "\n",varargin{2:end})
        end
        
        function rethrow(obj,varargin) %#ok<INUSL>
            rethrow(varargin{:})
        end
        
    end
    
    %% STATIC METHODS
    methods (Static)
       
        function varargout = runOnLocal(varargin)
                   
            proj = ci.openProject();
            
            if ispc()
                host = "windows";
                suffix = "vs";
            else
                host = "linux";
                suffix = "";
            end
            
            installationfolder = fullfile(proj.RootFolder, "deps");
            tempfolder = fullfile(tempdir, "ED247Cache");
            
            ed247folder     = fullfile(installationfolder, "ED247");
            qnxfolder       = fullfile(installationfolder, "QNX");
            
            obj = ci.Dependencies( proj.RootFolder, ed247folder, qnxfolder, tempfolder, ...
                "BranchName",   "master",                       ...
                "Host",         host,                           ...
                "ProjectID",    "314",                          ...
                "ServerURL",    "http://gnb-csg-master:8484",   ...
                "Suffix",       suffix,                         ...
                "Target",       "qnx",                          ...
                "Token",        "TGyAPFRAZzRQAzyBNTxB"          ...
                );
            
            cleanup(obj)
            download(obj)
            install(obj)
            configure(obj)
            
            if nargout
                varargout = {obj};
            end
            
        end
        
        function runOnGitLabCI(varargin)
           
            status = -1;
            
            try
                
                proj = ci.openProject();
                
                if ispc()
                    host = "windows";
                    suffix = "vs";
                else
                    host = "linux";
                    suffix = "";
                end
                
                tempfolder = fullfile(tempdir, "ED247Cache");
                
                branchname = getenv("ARTIFACT_PROJECT_BRANCH");
                projectid  = getenv("ARTIFACT_PROJECT_ID");
                token      = getenv("ARTIFACT_PROJECT_TOKEN");
                
                ed247folder     = getenv("ED247_LOC");
                qnxfolder       = getenv("QNX_LOC");
                
                obj = ci.Dependencies( proj.RootFolder, ed247folder, qnxfolder, tempfolder, ...
                    "BranchName",   branchname,                     ...
                    "Host",         host,                           ...
                    "ProjectID",    projectid,                      ...
                    "ServerURL",    "http://gnb-csg-master:8484",   ...
                    "Suffix",       suffix,                         ...
                    "Target",       "qnx",                          ...
                    "Token",        token                           ...
                    );
                
                download(obj)
                install(obj)
                
                status = 0;
                
            catch me
                disp(me.getReport())
            end
            
            quit(status)
            
        end
        
    end
    
end