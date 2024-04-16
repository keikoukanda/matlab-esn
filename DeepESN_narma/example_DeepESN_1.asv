function example_DeepESN_1

task = example_task_Narma(); 

repetitions = 1; %number of network gueses for each reservoir hyper-parametrization
rho_values = 0.9; %explored values of the spectral radius
mean_NARMA_score = zeros(1,repetitions);
networks = cell(length(rho_values),repetitions); %to contain the initialized DeepESNs explored in the model selection phase


for i_rho = 1:length(rho_values)
    fprintf('-');
    rho = rho_values(i_rho);
    % change this parameter
    scale = 0.1;
    for i = 1:repetitions
        rng(1)
        fprintf('=');
        net = DeepESN(); %create the DeepESN
        % set the hyper-parameters: -----
        net.spectral_radius = rho;
        net.Nr = 10; %10 reservoir units
        net.Nl = 10; %10 reservoir layers
        %input scaling is set to 0.1, with scaling mode 'byrange'
        net.input_scaling = scale;
        net.inter_scaling = scale; %do the same also for the inter-layer scaling
        net.input_scaling_mode = 'byrange';
        net.washout = 1000; %1000 time steps long transient
        % --------------------------------
        
        net.initialize; %initialize the DeepESN
        %save the DeepESN for future use
        networks{i_rho,i} = net;
        
        %train the network and compute the tr and vl performance
        [~,output_vl] = net.train_test(task.input,task.target,task.folds{1}.training{1},task.folds{1}.validation{1});
        % task.target(:,task.folds{1}.validation{1}) を double 型に変換
        target_validation = double(task.target(:,task.folds{1}.validation{1}));

        % DeepESN.getErr 関数に変換された値を渡す
        mean_NARMA_score(1,i) = DeepESN.getErr(target_validation, output_vl);
        % mean_NARMA_score(i) = DeepESN.getErr(task.target(:,task.folds{1}.validation{1}),output_vl);
        narma(:,i) = mean_NARMA_score(i);

        % 
        % scale = scale + 0.1;
    end
    fprintf('> "=" is amount of repetation, "-" is length of rho_values');
    fprintf('\n -- Parameter for confirm -- \n');
    fprintf('   Nr: %d\n', net.Nr);
    fprintf('   Nl: %d\n', net.Nl);
    fprintf('   Input scaling: %.2f\n', net.input_scaling);
    fprintf('   Rho values: %.2f\n', rho_values);
    fprintf('   Mean NARMA score: %.3f\n', narma);

    % plot nrmse 14 april===========
    % scaling = 0.1:0.1:1.0;
    % plot(scaling,mean_NARMA_score, 'o-', 'MarkerSize', 8, 'LineWidth', 2)
    % title('NRMSE Plot', 'FontSize', 24);
    % xlabel('scaling', 'FontSize', 24);
    % ylabel('NRMSE Value', 'FontSize', 24);
    % hold on
    % grid on
    % plot nrmse 14 april===========
end



% for i_rho = 1:length(rho_values)
% plot(NARMA_score{i_rho}(1))
% end
% hold on
% grid on
% legend_cell = cellstr(num2str(rho_values', 'rho = %.1f'));
% title('NRMSE'); legend(legend_cell);
