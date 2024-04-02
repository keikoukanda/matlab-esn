function example_DeepESN_1
%Example of usage of DeepESN and Task classes.
%The reported code performs a model selection on the spectral radius of the reservoir layers 
%considering the short-term Memory Capacity (MC) as learning task. 
%In particular, the MC task is set up to be used with a maximum number of 100 reservoir units.
%In this example, DeepESNs with 10 layers of 10 reservoir units are considered.
%The task information for this example is given in the MC100.mat file.
%For further information see the comments reported in the code of this function.
%
%
%This file is part of the DeepESN19a Toolbox, February 2019
%Claudio Gallicchio
%gallicch@di.unipi.it - https://sites.google.com/site/cgallicch/
%
%Department of Computer Science - University of Pisa (Italy)
%Computational Intelligence & Machine Learning (CIML) Group
%
%Reference article:
%C. Gallicchio, A. Micheli, L. Pedrelli, "Deep Reservoir Computing: A
%Critical Experimental Analysis", Neurocomputing, 2017, vol. 268, pp. 87-99
%default option use load following line
% load MC100.mat task %loads the task data and folds description

% alternatively, create the task obkect (uncomment the following line)
% task = example_task_MC();
task = narma_x_task();

repetitions = 5; %number of network gueses for each reservoir hyper-parametrization
rho_values = 0.9; %explored values of the spectral radius
MC_score_validation = cell(length(rho_values),1);%to contain the MC scores on the validation set for all the explored hyper-parametrizations
networks = cell(length(rho_values),repetitions); %to contain the initialized DeepESNs explored in the model selection phase

selected_rho = 0; %to contain the index to the selected value of rho
best_validation_performance = 0; %to contain the best mean performance on the validation set

for i_rho = 1:length(rho_values)
    fprintf('-');
    rho = rho_values(i_rho);
    MC_score_validation{i_rho} = [];
    for i = 1:repetitions
        fprintf('=');
        net = DeepESN(); %create the DeepESN
        % set the hyper-parameters: -----
        net.spectral_radius = rho;
        net.Nr = 10; %10 reservoir units
        net.Nl = 10; %10 reservoir layers
        %input scaling is set to 0.1, with scaling mode 'byrange'
        net.input_scaling = 1;
        net.inter_scaling = 1; %do the same also for the inter-layer scaling
        net.input_scaling_mode = 'byrange';
        net.washout = 1000; %1000 time steps long transient
        d=zeros(size(task.target(:,task.folds{1}.test),1), repetitions);
        % --------------------------------
        
        net.initialize; %initialize the DeepESN
        %save the DeepESN for future use
        networks{i_rho,i} = net;
        
        %train the network and compute the tr and vl performance
        [~,output_vl] = net.train_test(task.input,task.target,task.folds{1}.training{1},task.folds{1}.validation{1});

%% this part is calculating MC score <<<< 1
        % % %compute the MC score of this network on the validation set
        % MC_score_validation{i_rho}(i) = DeepESN.MCscore(task.target(:,task.folds{1}.validation{1}),output_vl);
% >>>>>>>>>>>>>>

    end
    %compute the mean performance of this hyper-parametrization on the validation set
    mean_validation_performance_vl = mean(MC_score_validation{i_rho});
    %update the best result if it is the case (i.e., if it is the first hyper-parametrization
    %considered, or if the mean performance achieved by this hyper-parametrization is better
    %than the highest validation performance so far
    if ((i_rho ==1)||(mean_validation_performance_vl > best_validation_performance))
        best_validation_performance = mean_validation_performance_vl;
        selected_rho = i_rho;
    end
end
%the selected value of rho is rho_values(i_rho)

%train the networks corresponding to the selected hyper-parametrization on the design set and evaluate
%the performance on the test set
%% this part is calculating MC score <<<< 1
MC_score_design = zeros(1,repetitions);%to contain the MC score on the design set
MC_score_test = zeros(1,repetitions);%to contain the MC score on the test set
%>>>>>>>>>>>

for i = 1:repetitions
    %train the i-th DeepESN repetition on the design set, and evaluate the achieved performance on
    %both the design and the test sets
    [output_tr,output_ts] = networks{selected_rho,i}.train_test(task.input,task.target,task.folds{1}.design,task.folds{1}.test);
    
%% this part is calculating MC score <<<< 1

    % % %compute the scores on the design set and on the test set
    % MC_score_design(i) = DeepESN.MCscore(task.target(:,task.folds{1}.design(net.washout+1:end)),output_tr);
    % [MC_score_test(i),d(:,i),delays] = DeepESN.MCscore(task.target(:,task.folds{1}.test),output_ts);

% >>>>>>>>>>>>>>>>
end

%print a message to report the outcomes of the experiment
fprintf('Selected value of rho = %f.\n',rho_values(selected_rho));
%% this part is calculating MC score <<<< 1

% fprintf('MC score on the training set = %f (%f).\n',mean(MC_score_design),std(MC_score_design));
% fprintf('MC score on the test set = %f (%f).\n',mean(MC_score_test),std(MC_score_test));   

% >>>>>>>>>>>>
%% visualize

%%%%=================%%%%
%plot MC


% MC_score_test is result of MC result in each repitation
% for p=1:30
%     LineWidth = 2;
%     semilogx(p,mean(MC_score_test));
% end
% plot([1:1:delays] , mean(d,2));

errorbar([1:1:delays] , mean(d,2), std(d, [] , 2)/sqrt(repetitions),'LineWidth',2);

% % ++ design
ylim([0 1])
h_axes = gca;
h_axes.XAxis.FontSize = 30;
h_axes.YAxis.FontSize = 30;
legend('scale = 0.1', 'scale = 1')
hold on
%plot MC
%%%%=================%%%%
