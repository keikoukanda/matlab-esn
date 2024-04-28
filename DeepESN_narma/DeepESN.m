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
            self.default();
            end
            
            
            function init_state(self)
            for layer = 1:self.Nl
                self.state{layer} = self.initial_state;
                self.l_state{layer} = [];
                self.run_states{layer} = [];
                
            end
            end
            function initialize(self)
            %initialize the input-reservoir weight matrix
            self.Win = 2*rand(self.Nr,self.Nu+1)-1;
            %scale the input-to-reservoir weight matrix
            switch self.input_scaling_mode
                case 'bynorm'
                    self.Win = self.input_scaling * self.Win / norm(self.Win);
                case 'byrange'
                    self.Win = self.Win * self.input_scaling;
            end
            
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
    
            for i = 1:self.Nl
                self.W{i} = 2*rand(self.Nr,self.Nr)-1;
                I = eye(self.Nr);
                Wt = (1-self.leaking_rate) * I + self.leaking_rate * self.W{i};
                Wt = self.spectral_radius * Wt / max(abs(eig(Wt)));
                self.W{i} = (Wt - (1-self.leaking_rate) * I)/self.leaking_rate;
            end
            self.initial_state = zeros(self.Nr,1);
            self.init_state();
            end
    
            function states = run(self,input)
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
                    % u = [];
                    % input_part = [];
                    if layer == 1
                        u = input(1,t);
                        input_part = self.Win * [u;self.bias];
                    else
                        u = self.run_states{layer-1}(:,t);
                        %the output of the previous layer
                        input_part = self.Wil{layer} * [u;self.bias];
                    end
                    self.state{layer} = (1-self.leaking_rate) * x + self.f(input_part + self.W{layer} * x);
                    self.run_states{layer}(:,t) = self.state{layer};
                    self.l_state{layer}(:,t) = self.state{layer};
                    
                    old_state{layer} = self.state{layer};
                end
            end
            % for layer = 1:self.Nl
            %     writematrix(self.l_state{layer}, "1state_"+ num2str(layer) + ".csv");
            % end
            states = self.run_states;
            end
    
    
            % traing Wout here==
            function self = train_readout(self,target)
            X = self.shallow_states(self.run_states);
            % remove the washout transient
            X = X(:,self.washout+1:end);
            target = target(:,self.washout+1:end);
            % add the input bias
            X = [X;self.bias * ones(1,size(X,2))];
            if self.readout_regularization == 0
                self.Wout = target * pinv(X);
            else
                self.Wout = target * X' / (X*X'+self.readout_regularization *eye(size(X,1)));
            end
            self.Ny = size(self.Wout,1); %also adjust the self.Ny value to the correct one given the target
            end
    
            function states = train(self, input, target)
            states = self.run(input);
            self.train_readout(target);
            end
    
            function output = compute_output(self,states,remove_washout)
            states = self.shallow_states(states);
            if remove_washout
                states = states(:,self.washout+1:end);
            end
            output = self.Wout * [states;self.bias * ones(1,size(states,2))];
            end  
    
            function [outputTR,outputTS] = train_test(self,input,target,training,test)
            %initialize the state
            self.init_state(); 
            
            %train the network
            training_input = input(:,training);
            training_target = target(:,training);
            training_states = self.train(training_input,training_target);
            
            %compute the output of the model on the training set
            outputTR = self.compute_output(training_states,1);
            
            %compute the output of the model on the assessment data
            %first compute the states
            test_input = input(:,test);
            test_states = self.run(test_input); %here do not re-initialize the state
            outputTS = self.compute_output(test_states,0);
            end  
        
        end


    % methods (Static)
    %     function NRMSE = getErr(target, output)
    %         % Set up initial parameters
    %         num_time_steps = length(target);
    %         e = zeros(num_time_steps, 1);
    %         MSE = zeros(num_time_steps, 1);
    %         NRMSE = zeros(num_time_steps, 1);
    % 
    %         for time = 1:num_time_steps
    %             e(time) = output(time) - target(time);
    %             MSE(time) = e(time)^2;
    %         end
    % 
    %         mean_MSE = mean(MSE);
    %         NRMSE = sqrt(mean_MSE) / (max(target) - min(target));
    %     end
    % end

%         function NRMSE = getErr(target, output)
%     % Set up initial parameters
%     num_time_series = size(target, 2); % Assume target and output have the same length
%     num_time_steps = size(target, 1);
%     NRMSE = zeros(num_time_series, 1);
%     % 
% 
% 
% % % %plot the state of target and output
% % % % Define the time range
% % % time_range = 1:200;
% % % 
% % % % Plot the data within the time range
% % % plot(time_range, target(time_range))
% % % hold on
% % % plot(time_range, output(time_range))
% % % xlabel('Time-series')
% % % ylabel('State')
% % % legend('Target', 'Output')
%                 e = zeros(num_time_series, 1);
%                 MSE = zeros(num_time_series, 1);
% 
%                 for time = 1 : num_time_series
%                     e(time) = output(time, serieime = 1:num_time_stepss) - target(time, series);
%                     MSE(time) = e(time)^2;
%                 end
% 
%                 mean_MSE = mean(MSE);
%                 NRMSE(series) = sqrt(mean_MSE) / (max(target(:, series)) - ...
%                     min(target(:, series)));
%         end
    methods (Static)
        function mean_nrmse_values = getErr(target, output)
            %Compute the Mean Squared Error given target and output data.
            target1 = target;
            output1 = output;
            [~, time_series] = size(target1);
            nrmse_values = zeros(1, time_series);
            mse_values = mean((target1 - output1).^2);
            % mean_nrmse_values = 0;
            for i = 1:time_series
                mean_value = mean(target1(:, i));
                rmse_value = sqrt(mse_values);
                nrmse_values(i) = rmse_value / mean_value;
            end
            mean_nrmse_values = mean(nrmse_values);

            % variable_type = class(mean_nrmse_values);
            % disp(variable_type);
            % plot output and target
            % plot(1:1000, target(1,:), 'LineWidth', 2)
            % hold on
            % plot(1:1000, output(1,:), 'LineWidth', 2)
            % title('output', 'FontSize', 24)
            % legend('target', 'output', 'FontSize', 24)

            %Nrmse plot
            % hold on
            % plot(nrmse_values, 'LineWidth', 2);
            % title('NRMSE Plot', 'FontSize', 24);
            % xlabel('Time Series', 'FontSize', 24);
            % ylabel('NRMSE Value', 'FontSize', 24);
        end
    end
        

    methods (Access = private)
        function X = shallow_states(self,states)
        
        Nt = size(states{1},2); %number of time steps
        X = zeros(self.Nl * self.Nr,Nt); %this matrix will contain the input for the readout
        %i.e., for each time step (column): the states computed at each layer of the reservoir
        %concatenated along the rows dimension.
        for t = 1:Nt
            for layer = 1:self.Nl
                X(1+(layer-1)*self.Nr:self.Nr+(layer-1)*self.Nr,t) = states{layer}(:,t);
            end
        end
        end
    end

    
end