classdef (SharedTestFixtures={ ...
        matlab.unittest.fixtures.PathFixture(fullfile(regexprep(mfilename('fullpath'),'\+.*',''),'_files'))}) ...
        SFunctionBlockTest < matlab.unittest.TestCase
   
    %% CLASS SETUP
    methods (TestClassSetup)
       
        function compileSFunction(testCase) %#ok<MANU>
           
            if exist('ed247_sfun','file') ~= 3
                ed247.compile()
            end
            
        end
        
    end
    
    %% TESTS
    methods (Test)
       
        function testConstructor(testCase)
            
            % [ SETUP ]
            blockname = '';
            
            % [ EXERCISE ]
            f = @() ed247.SFunctionBlock(blockname);
            
            % [ VERIFY ]
            testCase.verifyWarningFree(f)
            
        end
        
        function testGetConfigurationFileinPath(testCase)
            
            % [ SETUP ]
            modelname = 'mockmodel';
            blockname = strjoin({modelname,'fortest'},'/'); 
            configurationfile = 'config_arrays.txt';
            
            new_system(modelname)
            c = onCleanup(@() bdclose(modelname));
            add_block('simulink/Ports & Subsystems/Subsystem',blockname)
            p = Simulink.Mask.create(blockname);
            p.addParameter('Name','configurationFilename','Evaluate','off');
            
            set_param(blockname,'configurationFilename',sprintf('''%s''',configurationfile))
            
            ivn = ed247.SFunctionBlock(blockname);
            
            % [ EXERCISE ]
            actual = ivn.ConfigurationFileInt8;
            
            % [ VERIFY ]
            expected = which(configurationfile);
            expected = int8([expected,0]);
            testCase.verifyEqual(actual,expected)
            
        end
        
        function testGetConfigurationFileAbsPath(testCase)
            
            % [ SETUP ]
            modelname = 'mockmodel';
            blockname = strjoin({modelname,'fortest'},'/'); 
            configurationfile = fullfile(tempdir(),'testGetConfigurationFileAbsPath.txt');
            fid = fopen(configurationfile,'wt');fclose(fid);
            
            new_system(modelname)
            c = { ...
                onCleanup(@() bdclose(modelname)); ...
                onCleanup(@() delete(configurationfile)); ...
                }; %#ok<NASGU>
            add_block('simulink/Ports & Subsystems/Subsystem',blockname)
            p = Simulink.Mask.create(blockname);
            p.addParameter('Name','configurationFilename','Evaluate','off');
            
            set_param(blockname,'configurationFilename',sprintf('''%s''',configurationfile))
            
            ivn = ed247.SFunctionBlock(blockname);
            
            % [ EXERCISE ]
            actual = ivn.ConfigurationFileInt8;
            
            % [ VERIFY ]
            expected = int8([configurationfile,0]);
            testCase.verifyEqual(actual,expected)
            
        end
        
        function testGetConfigurationFileVariable(testCase)
            
            % [ SETUP ]
            modelname = 'mockmodel';
            blockname = strjoin({modelname,'fortest'},'/'); 
            configurationfile = fullfile(tempdir(),'testGetConfigurationFileVariable.txt');
            fid = fopen(configurationfile,'wt');fclose(fid);
            
            new_system(modelname)
            c = { ...
                onCleanup(@() bdclose(modelname)); ...
                onCleanup(@() delete(configurationfile)); ...
                onCleanup(@() evalin('base','clear(''configurationfile'')')); ...
                }; %#ok<NASGU>
            add_block('simulink/Ports & Subsystems/Subsystem',blockname)
            p = Simulink.Mask.create(blockname);
            p.addParameter('Name','configurationFilename','Evaluate','off');
            
            assignin('base','configurationfile',configurationfile)
            set_param(blockname,'configurationFilename','configurationfile')
            
            ivn = ed247.SFunctionBlock(blockname);
            
            % [ EXERCISE ]
            actual = ivn.ConfigurationFileInt8;
            
            % [ VERIFY ]
            expected = int8([configurationfile,0]);
            testCase.verifyEqual(actual,expected)
            
        end
        
        function testGetLogFileEnabled(testCase)
            
            % [ SETUP ]
            modelname = 'mockmodel';
            blockname = strjoin({modelname,'fortest'},'/'); 
            logfile = fullfile(tempdir(),'testGetLogFileAbsPath.txt');
                        
            new_system(modelname)
            c = { ...
                onCleanup(@() bdclose(modelname)); ...
                }; %#ok<NASGU>
            add_block('simulink/Ports & Subsystems/Subsystem',blockname)
            p = Simulink.Mask.create(blockname);
            p.addParameter('Name','logFilename','Evaluate','off');
            p.addParameter('Name','enableLog','Evaluate','off');
            
            set_param(blockname,'enableLog','on','logFilename',sprintf('''%s''',logfile))
            
            ivn = ed247.SFunctionBlock(blockname);
            
            % [ EXERCISE ]
            actual = ivn.LogFileInt8;
            
            % [ VERIFY ]
            expected = int8([logfile,0]);
            testCase.verifyEqual(actual,expected)
            
        end
        
        function testGetLogFileDisabled(testCase)
            
            % [ SETUP ]
            modelname = 'mockmodel';
            blockname = strjoin({modelname,'fortest'},'/'); 
            logfile = fullfile(tempdir(),'testGetLogFileAbsPath.txt');
                        
            new_system(modelname)
            c = { ...
                onCleanup(@() bdclose(modelname)); ...
                }; %#ok<NASGU>
            add_block('simulink/Ports & Subsystems/Subsystem',blockname)
            p = Simulink.Mask.create(blockname);
            p.addParameter('Name','logFilename','Evaluate','off');
            p.addParameter('Name','enableLog','Evaluate','off');
            
            set_param(blockname,'enableLog','off','logFilename',sprintf('''%s''',logfile))
            
            ivn = ed247.SFunctionBlock(blockname);
            
            % [ EXERCISE ]
            actual = ivn.LogFileInt8;
            
            % [ VERIFY ]
            expected = int8(0);
            testCase.verifyEqual(actual,expected)
            
        end
        
    end
    
end