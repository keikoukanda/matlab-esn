

%% visualize
washout = 1000;

input(:,1) = readmatrix("Narma_input.csv");
target(:,1) = readmatrix("Narma_target.csv");
output(:,1) = readmatrix("outputTR.csv");

DeepOutput(:,1) = readmatrix("DeepESN_output.csv");
DeepOutput1(:,1) = readmatrix("DeepESN_output1.csv");

target_washout(:,1) = target(washout+1:4000, :);


% wash_out = 100;
% input_data = input(wash_out+1:2000, 1);
% target_data = target(wash_out+1:2000, 1);
% output_data = output(wash_out+1:2000, 1);


num_series = size(target_washout, 1);
NRMSE = zeros(1, num_series);

for i = 1:num_series
    % first get the raw error
    e1 = (DeepOutput1(i, :) - target_washout(i, :));
    e = (DeepOutput(i, :) - target_washout(i, :));

    % now get MSE
    MSE1 = mean(e1.^2);
    MSE = mean(e.^2);

    % now get NMSE
    % NMSE = MSE./var(target_washout(i, :));

    var_target = var(target_washout);

    % now get RNMSE
    % RNMSE(i, :) = sqrt(NMSE(i, :));

    % NRMSE
    % NRMSE(i, :) = sqrt(MSE(i, :))./(max(target_washout(i, :))-min(target_washout(i, :)));

    NRMSE1(i) = sqrt(MSE1 / var_target);
    NRMSE(i) = sqrt(MSE / var_target);

end

hold on
plot(NRMSE1);
plot(NRMSE);
title("NRMSE Plot for Output and Target")
legend('NRMSE-scaling1', 'NRMSE-scaling0.1')
xlabel('Time Series');
ylabel('NRMSE');

% visLen = 200;
% offset = 100;
% timeidx = [1:visLen]+offset;

%+++==============
% px = 1; py=2; %subplot
% subplot(py,px,1)
% % plot(input(timeidx,:))        
% plot(input(timeidx,:))
% title('input')
% subplot(py,px,2) 
% plot([output(timeidx,:) target(timeidx+3000,:)])
% % plot([output_data(timeidx,:) target_data(timeidx+2000,:)])
% title('output'); legend('output','target');
%+++==============

% plot([DeepOutput1 target_washout])
% title('output'); legend('output','target');

