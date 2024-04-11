function example_DeepESN_1

task = example_task_Narma(); 

repetitions = 1; %number of network gueses for each reservoir hyper-parametrization
rho_values = [0.1 0.5 0.9]; %explored values of the spectral radius
NARMA_score = cell(length(rho_values),1);
networks = cell(length(rho_values),repetitions); %to contain the initialized DeepESNs explored in the model selection phase


for i_rho = 1:length(rho_values)
    fprintf('-');
    rho = rho_values(i_rho);
    for i = 1:repetitions
        fprintf('=');
        net = DeepESN(); %create the DeepESN
        % set the hyper-parameters: -----
        net.spectral_radius = rho;
        net.Nr = 100; %10 reservoir units
        net.Nl = 10; %10 reservoir layers
        %input scaling is set to 0.1, with scaling mode 'byrange'
        net.input_scaling = 0.1;
        net.inter_scaling = 0.1; %do the same also for the inter-layer scaling
        net.input_scaling_mode = 'byrange';
        net.washout = 1000; %1000 time steps long transient
        % --------------------------------
        
        net.initialize; %initialize the DeepESN
        %save the DeepESN for future use
        networks{i_rho,i} = net;
        
        %train the network and compute the tr and vl performance
        [~,output_vl] = net.train_test(task.input,task.target,task.folds{1}.training{1},task.folds{1}.validation{1});
        NARMA_score = DeepESN.getErr(task.target(:,task.folds{1}.validation{1}),output_vl);
    end
end

% plot(NARMA_score)
% legend(nrmse)

% for i_rho = 1:length(rho_values)
% plot(NARMA_score{i_rho}(1))
% end
% hold on
% grid on
% legend_cell = cellstr(num2str(rho_values', 'rho = %.1f'));
% title('NRMSE'); legend(legend_cell);
