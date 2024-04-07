classdef DeepESN < handle

    properties
        Nr %Reservoir dimension (i.e., number of recurrent units) in each layer [default = 10]
        Nu %Input dimension (i.e., number of input units) [default = 1]
        Ny %Output dimension (i.e., number of readout units) [default = 1]
        Nl %Number of reservoir layers [default = 10]
        
        spectral_radius %Spectral radius of the recurrent reservoir matrix in each layer [default = 0.9]
        input_scaling %Scaling of input connections [default = 1]
        inter_scaling %Scaling of inter reservoir conenctions for each layer > 1 [default = 1]
        leaking_rate %Leaking rate of each reservoir layer (this should be in (0,1]) [default = 1]
        input_scaling_mode %A string that describes the way in which input and inter-reservoir connections are scaled
        % e.g., 'bynorm' (scales the 2-norm of the matrices), 
        %       or 'byrange' (scales the interval from which to choose the weight values)
        % [default = 'bynorm']
        f %Activation function of the reservoir units (e.g., @tanh) [default = @tanh]
        bias %Input bias for reservoir and readout [default = 1]
        washout %Transient period for states washout [default = 1000]
        
        readout_regularization %Lambda for ridge regression training of the readout [default = 0]
        
        Win %Input-to-reservoir weight matrix
        Wil %Cell structure containing the inter-layer reservoir weight matrices. For each l > 1, Wil{l} contains
        % the weight values for the connections from layer (l-1) to layer l.
        W %Cell structure containing the recurrent reservoir weight matrices. For each l>1, W{l} contains
        % the recurrent weight values for layer l
        Wout %Reservoir-to-readout weight matrix
        
        run_states %Nr x Nt reservoir activation matrix corresponding to the last reservoir run (Nt is the number of time steps)
        initial_state %Initial state for the reservoir in each layer. This is a vector of size Nr x 1, used for all the Nl layers.
        state %Cell structure where the l-th element contains the present state of the reservoir in layer l

        l_state % state of layer
        
        output1
        target1
        
    end
        methods (Access = public)
        
            function self = default(self)
            %Set default values for the DeepESN properties
            self.Nr = 10;
            self.Nu = 1;
            self.Ny = 1;
            self.Nl = 10;
            
            self.spectral_radius = 0.9;
            self.input_scaling = 1;
            self.inter_scaling = 1;
            self.leaking_rate = 1;
            self.input_scaling_mode = 'bynorm';
            self.f = @tanh;
            self.bias = 1;
            self.washout = 1000;       
            
            self.readout_regularization = 0;
            
            self.Win = [];
            self.Wil = cell(self.Nl,1);
            self.W = cell(self.Nl,1);
            self.Wout = [];
            
            self.run_states = cell(self.Nl,1);
            self.initial_state = [];
            self.state = cell(self.Nl,1);
            self.l_state = cell(self.Nl,1);
    
            self.output1 = [];
            self.target1 = [];
            end
        
        function self = DeepESN()
        %Class constructor. Set all the DeepESN properties to the default values
        self.default();
        end
        
        
        function init_state(self)
        %(Re-)initialize the state in each layer of the deep reservoir to initial_state
        for layer = 1:self.Nl
            self.state{layer} = self.initial_state;
            self.l_state{layer} = [];
            self.run_states{layer} = [];
            
        end
        end
        function initialize(self)
        %Initialize the deep reservoir of the DeepESN. This involves (i) setting up all the weight
        %matrices, and (ii) setting up the state of the deep reservoir
        
        %initialize the input-reservoir weight matrix
        self.Win = 2*rand(self.Nr,self.Nu+1)-1;
        %scale the input-to-reservoir weight matrix
        switch self.input_scaling_mode
            case 'bynorm'
                self.Win = self.input_scaling * self.Win / norm(self.Win);
            case 'byrange'
                self.Win = self.Win * self.input_scaling;
        end
        
        %initialize the inter-reservoir weight matrices
        for i = 2:self.Nl
            %initialization of the i-th inter-layer weight matrix
            self.Wil{i} = 2*rand(self.Nr,self.Nr+1)-1;
            %scaling of the i-th inter-layer weight matrix
            switch self.input_scaling_mode
                case 'bynorm'
                    self.Wil{i} = self.inter_scaling * self.Wil{i} / norm(self.Wil{i});
                case 'byrange'
                    self.Wil{i} = self.Wil{i} * self.inter_scaling;
            end
        end
        
        %initialize the recurrent reservoir weight matrices
        for i = 1:self.Nl
            %initialization of the i-th recurrent weight matrix
            self.W{i} = 2*rand(self.Nr,self.Nr)-1;
            %scaling of the i-th recurrent weight matrix
            I = eye(self.Nr);
            Wt = (1-self.leaking_rate) * I + self.leaking_rate * self.W{i};
            Wt = self.spectral_radius * Wt / max(abs(eig(Wt)));
            self.W{i} = (Wt - (1-self.leaking_rate) * I)/self.leaking_rate;
        end
        
        %initialize the state of the reservoir in each layer to a zero state
        self.initial_state = zeros(self.Nr,1);
        self.init_state();
        %note: if you need to initialize the reservoir states to an initial condition different
        %from the zero state, set the initial_state property to the desired initial conditions
        %and then call the init_state() method
        end

        function states = run(self,input)
        %Run the deep reservoir on the given input, returning the computed states.
        %Note(s):
        % - the execution of this function stores the computed states into the run_states property of
        % the DeepESN object
        % - this method does not reset the state of the reservoir to the initial conditions, call
        % method init_state (before this method) if you need to reset the state to initial
        % conditions before computing the reservoir states
        %
        % Parameter(s):
        % - input: An Nu x Nt matrix representing the input time-series.
        %          input(:,t) is input at time step t
        % Returned value(s):
        % - states: An Nlx1 cell containing the states computed by each layer of the deep reservoir.
        %           For each layer l, states{l} is an Nr x Nt matrix. 
        %           In particular, states{l}(:,t) is the state of the l-th reservoir layer at time step t
        
        Nt = size(input,2); %number of time steps in the input time-series
        % prepare the self.run_states variable
        for layer = 1:self.Nl
            self.run_states{layer} = zeros(self.Nr,Nt);
        end
        
        %run the deep reservoir on the given input
        old_state = self.state; %this is the first state
        for t = 1:Nt
            % t - time step under consideration
            for layer = 1:self.Nl
                % layer - layer under consideration
                x = old_state{layer}; %this plays the role of previous state
                u = []; %input for this specific layer
                %now focus on the specific input for the layer and compute the input_part in the
                %state update equation
                % (also the input bias is concatenated to the proper input)
                input_part = [];
                if layer == 1
                    u = input(:,t); %only the first layer receives the external input
                    input_part = self.Win * [u;self.bias];
                else
                    u = self.run_states{layer-1}(:,t); %successive layers receive in input
                    %the output of the previous layer
                    input_part = self.Wil{layer} * [u;self.bias];
                end
                self.state{layer} = (1-self.leaking_rate) * x + self.f(input_part + self.W{layer} * x);
                self.run_states{layer}(:,t) = self.state{layer};
                old_state{layer} = self.state{layer};
            end
        end
        states = self.run_states;
        end

        

        
        end
end