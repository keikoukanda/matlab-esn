classdef Task < handle
    
    properties
        name %A string name for the task
        input
        target
        folds    
    end
    methods (Access = public)
        function self = default(self)
        %Set all the Task properties to the default values
            self.input = [];
            self.target = [];
            self.folds = cell(0,0);
            self.name = 'Default Task';
        end
        
        function self = Task()
        %Class constructor. Just set all the Task properties to the default values
            self.default();
        end
        
        %The following methods are used to fill the dataset with the needed information
        function self = set_name(self,name)
        %Set the name of the task
            self.name = name;
        end
        function self = set_data(self,input,target)
           
            if (size(input,2)~=size(target,2))
                warning('Input and target time-series should be of the same length.');
            else
                self.input = input;
                self.target = target;
            end
        end
        
        function self = set_holdout_folds(self,training,validation,design,test)
        
        self.folds = [];
        self.folds{1}.design = design;
        self.folds{1}.test = test;
        self.folds{1}.training{1} = training;
        self.folds{1}.validation{1} = validation;
        end
 
    end
end