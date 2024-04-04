function example_DeepESN_1
    % Load necessary libraries and define DeepESN and NARMA10 task
    addpath(pwd); % Add path to the narmax.m file
    % Alternatively, create the task object (uncomment the following line)
    % task = example_task_MC(); 

    % Repetitions and explored values
    repetitions = 5;
    rho_values = 0.9;
    NARMA10_score_validation = cell(length(rho_values),1);
    networks = cell(length(rho_values),repetitions);

    selected_rho = 0;
    best_validation_performance = 0;

    % Loop over explored values of rho
    for i_rho = 1:length(rho_values)
        fprintf('-');
        rho = rho_values(i_rho);
        NARMA10_score_validation{i_rho} = []; % NARMA10_score_validationを初期化
        for i = 1:repetitions
            fprintf('=');
            net = DeepESN();
            % Set hyper-parameters
            net.spectral_radius = rho;
            net.Nr = 10;
            net.Nl = 10;
            net.input_scaling = 1;
            net.inter_scaling = 1;
            net.input_scaling_mode = 'byrange';
            net.washout = 1000;
            % Initialize DeepESN
            net.initialize();
            networks{i_rho,i} = net;

            % Generate input sequence for NARMA10 task
            input_length = 1000;
            input_sequence = rand(input_length, 1); % Modify input generation as needed

            % Generate NARMA10 output
            narma_output = narmax(input_sequence, 10, 0); % Assuming order 10
            
            % Create the NARMA10 task directly without using CSV files
            task = example_task_NARMA10();
            
            % Get input and target data for the NARMA10 task
            narma_input = task.input;
            narma_target = task.target;

            % Train the network and compute performance on validation set
            [~, output_vl] = net.train_test(narma_input, narma_target, [], []);

            % Compute MSE on validation set
            NARMA10_score_validation{i_rho}(i) = calculate_MSE(task.target(:, task.folds{1}.validation{1}), output_vl);
        end
        % Compute mean performance on validation set
        mean_validation_performance_vl = mean(NARMA10_score_validation{i_rho});
        % Update best result
        if ((i_rho ==1)||(mean_validation_performance_vl > best_validation_performance))
            best_validation_performance = mean_validation_performance_vl;
            selected_rho = i_rho;
        end
    end

    % Train networks corresponding to the selected hyper-parameterization on design set and evaluate on test set
    NARMA10_score_design = zeros(1, repetitions);
    NARMA10_score_test = zeros(1, repetitions);
    for i = 1:repetitions
        % Generate random input for NARMA10 task for design and test sets
        input_length = 1000;
        input_sequence_design = rand(input_length, 1); % Modify input generation as needed
        input_sequence_test = rand(input_length, 1);

        % Generate NARMA10 output for design set
        narma_output_design = narmax(input_sequence_design, 10, 0); % Assuming order 10

        % Train the network on design set
        [~,output_tr] = networks{selected_rho,i}.train_test(narma_output_design, task.target, [], []);

        % Generate NARMA10 output for test set
        narma_output_test = narmax(input_sequence_test, 10, 0); % Assuming order 10

        % Evaluate performance on test set
        [~,output_ts] = networks{selected_rho,i}.train_test(narma_output_test, task.target, [], []);

        % Compute MSE on design and test sets
        NARMA10_score_design(i) = calculate_MSE(task.target(:, task.folds{1}.design(net.washout+1:end)), output_tr);
        NARMA10_score_test(i) = calculate_MSE(task.target(:, task.folds{1}.test), output_ts);
    end

    % Print results
    fprintf('Selected value of rho = %f.\n',rho_values(selected_rho));
    fprintf('NARMA10 score on the training set = %f (%f).\n',mean(NARMA10_score_design),std(NARMA10_score_design));
    fprintf('NARMA10 score on the test set = %f (%f).\n',mean(NARMA10_score_test),std(NARMA10_score_test));  
end

function mse = calculate_MSE(target, output)
    mse = mean((target - output).^2);
end
