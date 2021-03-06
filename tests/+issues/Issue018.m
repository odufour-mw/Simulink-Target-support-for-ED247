classdef (SharedTestFixtures={...
        tools.WorkFolderFixture({'ED247','Issue018'})}) ...
        Issue018 < matlab.unittest.TestCase
    % ISSUE018
    %
    % Failed to read XML configuration files (ECIC/CMD)
    %
    % Extend tests to Configure/Receive/Send blocks configuration and
    % display with "big" XML file (Full ELAC)
    %
    
    %% CLASS SETUP
    methods (TestClassSetup)
        
        function setFileFolder(testCase)
            proj = currentProject();
            testCase.filefolder_ = fullfile(proj.RootFolder,'tests','_files');
        end
        
    end
    
    %% TESTS
    methods (Test)
        
        function testReadSimpleA429WithRefresh(testCase)
            
            % [ SETUP ]
            archivename = fullfile(testCase.filefolder_, 'A429_simple01.zip');
            unzip(archivename,pwd)
            
            modelname = 'readsimplea429';
            new_system(modelname)
            load_system(modelname)
            closeModel = onCleanup(@() bdclose(modelname));
            
            %
            % Add blocks in the model
            %
            configurationblockname = [modelname,'/Configure'];
            configurationblock = add_block('lib_ed247/ED247_Configuration', configurationblockname);
            
            receiveblockname = [modelname,'/Receive'];
            receiveblock = add_block('lib_ed247/ED247_Receive', receiveblockname);
            
            sendblockname = [modelname,'/Send'];
            sendblock = add_block('lib_ed247/ED247_Send', sendblockname);
            
            %
            % Configure blocks
            %   - configuration file
            %   - Enable refresh
            %
            set(configurationblock, 'configurationFilename', '''a429_01_ecic_in.xml''')
            set(receiveblock, 'enable_refresh', 'on', 'show_port_labels', 'on')
            set(sendblock, 'enable_refresh', 'on', 'show_port_labels', 'on')
            
            % [ EXERCISE ]
            % Run SIM to update diagram only (do not care about warnings)
            warning('off')
            sim(modelname,'StopTime','0');
            warning('on')
            
            % [ VERIFY ]
            %
            % Number of ports for Send and Receive blocks
            %
            receiveports = get(receiveblock,'PortHandles');
            testCase.verifyLength(receiveports.Outport,6, ...
                sprintf('[A429] Receive block should have %d ports (%d x2 as refresh is enabled)', 6, 3))
            
            sendports = get(sendblock,'PortHandles');
            testCase.verifyLength(sendports.Inport,4, ...
                sprintf('[A429] Send block should have %d ports (%d x2 as refresh is enabled)', 4, 2))
            
            %
            % Mask display (text and port labels)
            %
            
            % Displayed text should be empty as "Show port labels" is
            % enabled
            receivemask = ed247.blocks.Receive(receiveblock);
            testCase.verifyEmpty(receivemask.DisplayText, ...
                'No text should be displayed in Receive Mask as "Show port label" is enabled')
            
            % Displayed text should be empty as "Show port labels" is
            % enabled
            sendmask = ed247.blocks.Send(sendblock);
            testCase.verifyEmpty(sendmask.DisplayText, ...
                'No text should be displayed in Send Mask as "Show port label" is enabled')
            
            %
            % Port labels
            %
            actual = receivemask.PortLabel;
            Type = repmat({'output'},6,1);
            Number = (1:6)';
            Label = {'A429_BUS_1_MSG_1';'A429_BUS_1_MSG_1_refresh';'A429_BUS_1_MSG_2';'A429_BUS_1_MSG_2_refresh';'A429_BUS_1_MSG_3';'A429_BUS_1_MSG_3_refresh'};
            expected = table(Type,Number,Label);
            testCase.verifyEqual(actual,expected, ...
                'Receive port labels does not match expected')
            
            actual = sendmask.PortLabel;
            Type = repmat({'input'},4,1);
            Number = (1:4)';
            Label = {'A429_BUS_2_MSG_1';'A429_BUS_2_MSG_1_refresh';'A429_BUS_2_MSG_2';'A429_BUS_2_MSG_2_refresh'};
            expected = table(Type,Number,Label);
            testCase.verifyEqual(actual,expected, ...
                'Receive port labels does not match expected')
            
        end
        
        function testReadSimpleA429WithoutRefresh(testCase)
            
            % [ SETUP ]
            archivename = fullfile(testCase.filefolder_, 'A429_simple01.zip');
            unzip(archivename,pwd)
            
            modelname = 'readsimplea429';
            new_system(modelname)
            load_system(modelname)
            closeModel = onCleanup(@() bdclose(modelname));
            
            %
            % Add blocks in the model
            %
            configurationblockname = [modelname,'/Configure'];
            configurationblock = add_block('lib_ed247/ED247_Configuration', configurationblockname);
            
            receiveblockname = [modelname,'/Receive'];
            receiveblock = add_block('lib_ed247/ED247_Receive', receiveblockname);
            
            sendblockname = [modelname,'/Send'];
            sendblock = add_block('lib_ed247/ED247_Send', sendblockname);
            
            %
            % Configure blocks
            %   - configuration file
            %   - Disable refresh
            %
            set(configurationblock, 'configurationFilename', '''a429_01_ecic_in.xml''')
            set(receiveblock, 'enable_refresh', 'off')
            set(sendblock, 'enable_refresh', 'off')
            
            % [ EXERCISE ]
            % Run SIM to update diagram only (do not care about warnings)
            warning('off')
            sim(modelname,'StopTime','0');
            warning('on')
            
            % [ VERIFY ]
            receiveports = get(receiveblock,'PortHandles');
            testCase.verifyLength(receiveports.Outport,3, ...
                sprintf('[A429] Receive block should have %d ports (refresh is disabled)', 3))
            
            sendports = get(sendblock,'PortHandles');
            testCase.verifyLength(sendports.Inport,2, ...
                sprintf('[A429] Send block should have %d ports (refresh is disabled)', 2))
            
        end
        
        function testReadELACSimplifiedReceiveWithRefresh(testCase)
            
            % [ SETUP ]
            archivename = fullfile(testCase.filefolder_, 'ELAC_simplified.zip');
            unzip(archivename,pwd)
            
            modelname = 'readsimpleelac';
            new_system(modelname)
            load_system(modelname)
            closeModel = onCleanup(@() bdclose(modelname));
            
            %
            % Add blocks in the model
            %
            configurationblockname = [modelname,'/Configure'];
            configurationblock = add_block('lib_ed247/ED247_Configuration', configurationblockname);
            
            receiveblockname = [modelname,'/Receive'];
            receiveblock = add_block('lib_ed247/ED247_Receive', receiveblockname);
            
            %
            % Configure blocks
            %   - configuration file
            %   - Enable refresh
            %
            set(configurationblock, 'configurationFilename', '''ELACe2M_ECIC.xml''')
            set(receiveblock, 'enable_refresh', 'on')
            
            % [ EXERCISE ]
            % Run SIM to update diagram only (do not care about warnings)
            warning('off')
            sim(modelname,'StopTime','0');
            warning('on')
            
            % [ VERIFY ]
            receiveports = get(receiveblock,'PortHandles');
            testCase.verifyLength(receiveports.Outport,136, ...
                sprintf('[A429] Receive block should have %d ports (%d x2 as refresh is enabled)', 136, 68))
            
        end
                
        function testReadELACSimplifiedReceiveWithoutRefresh(testCase)
            
            % [ SETUP ]
            archivename = fullfile(testCase.filefolder_, 'ELAC_simplified.zip');
            unzip(archivename,pwd)
            
            modelname = 'readsimpleelac';
            new_system(modelname)
            load_system(modelname)
            closeModel = onCleanup(@() bdclose(modelname));
            
            %
            % Add blocks in the model
            %
            configurationblockname = [modelname,'/Configure'];
            configurationblock = add_block('lib_ed247/ED247_Configuration', configurationblockname);
            
            receiveblockname = [modelname,'/Receive'];
            receiveblock = add_block('lib_ed247/ED247_Receive', receiveblockname);
            
            %
            % Configure blocks
            %   - configuration file
            %   - Disable refresh
            %
            set(configurationblock, 'configurationFilename', '''ELACe2M_ECIC.xml''')
            set(receiveblock, 'enable_refresh', 'off')
            
            % [ EXERCISE ]
            % Run SIM to update diagram only (do not care about warnings)
            warning('off')
            sim(modelname,'StopTime','0');
            warning('on')
            
            % [ VERIFY ]
            receiveports = get(receiveblock,'PortHandles');
            testCase.verifyLength(receiveports.Outport,68, ...
                sprintf('[A429] Receive block should have %d ports (refresh is disabled)', 68))
            
        end
        
        function testReadELACFullConfigureOnly(testCase)
            
            % [ SETUP ]
            archivename = fullfile(testCase.filefolder_, 'ELAC_full.zip');
            unzip(archivename,pwd)
            
            modelname = 'readfullelac';
            new_system(modelname)
            load_system(modelname)
            closeModel = onCleanup(@() bdclose(modelname));
            
            %
            % Add blocks in the model
            %
            configurationblockname = [modelname,'/Configure'];
            configurationblock = add_block('lib_ed247/ED247_Configuration', configurationblockname);
                        
            %
            % Configure blocks
            %   - configuration file
            %   - Enable refresh
            %
            set(configurationblock, 'configurationFilename', '''ELACe2C_ECIC.xml''')
            
            % [ EXERCISE ]                        
            f = @() sim(modelname,'StopTime','0');            
            
            % [ VERIFY ]
            warning('off') % Run SIM to update diagram only (do not care about warnings)
            testCase.verifyWarningFree(f)
            warning('on')
            
        end
        
        function testReadELACFullReceiveWithRefresh(testCase)
            
            % [ SETUP ]
            % Load expected signals table
            expecteddatafile = fullfile(testCase.filefolder_, 'ELACe2C_ECIC.mat');
            expecteddata = load(expecteddatafile);
            expecteddata = expecteddata.Receive;
            
            archivename = fullfile(testCase.filefolder_, 'ELAC_full.zip');
            unzip(archivename,pwd)
            
            modelname = 'readfullelac';
            new_system(modelname)
            load_system(modelname)
            closeModel = onCleanup(@() bdclose(modelname));
            
            %
            % Add blocks in the model
            %
            configurationblockname = [modelname,'/Configure'];
            configurationblock = add_block('lib_ed247/ED247_Configuration', configurationblockname);
            
            receiveblockname = [modelname,'/Receive'];
            receiveblock = add_block('lib_ed247/ED247_Receive', receiveblockname);
            
            %
            % Configure blocks
            %   - Configuration file
            %   - Enable refresh
            %
            set(configurationblock, 'configurationFilename', '''ELACe2C_ECIC.xml''')
            set(receiveblock, 'enable_refresh', 'on', 'show_port_labels', 'on')
            
            % [ EXERCISE ]
            % Run SIM to update diagram only (do not care about warnings)
            warning('off')
            sim(modelname,'StopTime','0');
            sim(modelname,'StopTime','0'); % In some cases, 1 update is not enough to update port labels
            warning('on')
            
            % [ VERIFY ]
            receiveports = get(receiveblock,'PortHandles');
            testCase.verifyLength(receiveports.Outport,1060, ...
                sprintf('[Full ELAC] Receive block should have %d ports (%d signals + refresh)', 1060, 599))
            
            receiveportnames = get(receiveports.Outport,'Name');
            testCase.verifyTrue(all(ismember(expecteddata.SignalName,receiveportnames)), ...
                sprintf('[Full ELAC] All Received signals should appear as a block outport'))
            
            refreshsignals = expecteddata.SignalName(expecteddata.IsRefresh) + "_refresh";
            testCase.verifyTrue(all(ismember(refreshsignals,receiveportnames)), ...
                sprintf('[Full ELAC] All refreshed signals should appear as a block outport'))
            
        end
        
        function testReadELACFullReceiveWithoutRefresh(testCase)
            
            testCase.assumeTrue(false, "FIXME : Disabled for CI tests (not working yet)")
            
            % [ SETUP ]
            % Load expected signals table
            expecteddatafile = fullfile(testCase.filefolder_, 'ELACe2C_ECIC.mat');
            expecteddata = load(expecteddatafile);
            expecteddata = expecteddata.Receive;
            
            archivename = fullfile(testCase.filefolder_, 'ELAC_full.zip');
            unzip(archivename,pwd)
            
            modelname = 'readfullelac';
            new_system(modelname)
            load_system(modelname)
            closeModel = onCleanup(@() bdclose(modelname));
            
            %
            % Add blocks in the model
            %
            configurationblockname = [modelname,'/Configure'];
            configurationblock = add_block('lib_ed247/ED247_Configuration', configurationblockname);
            
            receiveblockname = [modelname,'/Receive'];
            receiveblock = add_block('lib_ed247/ED247_Receive', receiveblockname);
            
            %
            % Configure blocks
            %   - Configuration file
            %   - Enable refresh
            %
            set(configurationblock, 'configurationFilename', '''ELACe2C_ECIC.xml''')
            set(receiveblock, 'enable_refresh', 'off', 'show_port_labels', 'on')
            
            % [ EXERCISE ]
            % Run SIM to update diagram only (do not care about warnings)
            warning('off')
            sim(modelname,'StopTime','0');
            warning('on')
            
            % [ VERIFY ]
            receiveports = get(receiveblock,'PortHandles');
            testCase.verifyLength(receiveports.Outport,599, ...
                sprintf('[Full ELAC] Receive block should have %d ports', 599))
            
            receiveportnames = get(receiveports.Outport,'Name');
            testCase.verifyTrue(all(ismember(expecteddata.SignalName,receiveportnames)), ...
                sprintf('[Full ELAC] All Received signals should appear as a block outport'))
                        
        end
        
        function testReadELACFullSendWithRefresh(testCase)
            
            testCase.assumeTrue(false, "FIXME : Disabled for CI tests (not working yet)")
            
            % [ SETUP ]
            % Load expected signals table
            expecteddatafile = fullfile(testCase.filefolder_, 'ELACe2C_ECIC.mat');
            expecteddata = load(expecteddatafile);
            expecteddata = expecteddata.Send;
            
            archivename = fullfile(testCase.filefolder_, 'ELAC_full.zip');
            unzip(archivename,pwd)
            
            modelname = 'readfullelac';
            new_system(modelname)
            load_system(modelname)
            closeModel = onCleanup(@() bdclose(modelname));
            
            %
            % Add blocks in the model
            %
            configurationblockname = [modelname,'/Configure'];
            configurationblock = add_block('lib_ed247/ED247_Configuration', configurationblockname);
            
            sendblockname = [modelname,'/Send'];
            sendblock = add_block('lib_ed247/ED247_Send', sendblockname);
            
            %
            % Configure blocks
            %   - Configuration file
            %   - Enable refresh
            %
            set(configurationblock, 'configurationFilename', '''ELACe2C_ECIC.xml''')
            set(sendblock, 'enable_refresh', 'on', 'show_port_labels', 'on')
            
            % [ EXERCISE ]
            % Run SIM to update diagram only (do not care about warnings)
            warning('off')
            sim(modelname,'StopTime','0');
            warning('on')
            
            % [ VERIFY ]
            sendports = get(sendblock,'PortHandles');
            testCase.verifyLength(sendports.Inport,1066, ...
                sprintf('[Full ELAC] Send block should have %d ports (%d signals with %d refresh)', 1066, 573, 513))
                      
            sendobj = ed247.blocks.Send(sendblock);
            sendportnames = sendobj.PortLabel.Label;
            testCase.verifyTrue(all(ismember(expecteddata.SignalName,sendportnames)), ...
                sprintf('[Full ELAC] All Sent signals should appear as a block inport'))
            
            refreshsignals = expecteddata.SignalName(expecteddata.IsRefresh) + "_refresh";
            testCase.verifyTrue(all(ismember(refreshsignals,sendportnames)), ...
                sprintf('[Full ELAC] All refreshed signals should appear as a block inport'))
            
        end
        
        function testReadELACFullSendWithoutRefresh(testCase)
            
            % [ SETUP ]
            % Load expected signals table
            expecteddatafile = fullfile(testCase.filefolder_, 'ELACe2C_ECIC.mat');
            expecteddata = load(expecteddatafile);
            expecteddata = expecteddata.Send;
            
            archivename = fullfile(testCase.filefolder_, 'ELAC_full.zip');
            unzip(archivename,pwd)
            
            modelname = 'readfullelac';
            new_system(modelname)
            load_system(modelname)
            closeModel = onCleanup(@() bdclose(modelname));
            
            %
            % Add blocks in the model
            %
            configurationblockname = [modelname,'/Configure'];
            configurationblock = add_block('lib_ed247/ED247_Configuration', configurationblockname);
            
            sendblockname = [modelname,'/Send'];
            sendblock = add_block('lib_ed247/ED247_Send', sendblockname);
            
            %
            % Configure blocks
            %   - Configuration file
            %   - Enable refresh
            %
            set(configurationblock, 'configurationFilename', '''ELACe2C_ECIC.xml''')
            set(sendblock, 'enable_refresh', 'off', 'show_port_labels', 'on')
            
            % [ EXERCISE ]
            % Run SIM to update diagram only (do not care about warnings)
            warning('off')
            sim(modelname,'StopTime','0');
            warning('on')
            
            % [ VERIFY ]
            sendports = get(sendblock,'PortHandles');
            testCase.verifyLength(sendports.Inport,573, ...
                sprintf('[Full ELAC] Send block should have %d ports', 573))
                      
            sendobj = ed247.blocks.Send(sendblock);
            sendportnames = sendobj.PortLabel.Label;
            testCase.verifyTrue(all(ismember(expecteddata.SignalName,sendportnames)), ...
                sprintf('[Full ELAC] All Sent signals should appear as a block inport'))
            
        end
        
    end
    
    %% PRIVATE PROPERTIES
    properties (Access = private)
        filefolder_
    end
    
end