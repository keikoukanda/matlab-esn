

%% visualize
washout = 3000;

input(:,1) = readmatrix("Narma_input.csv");
target(:,1) = readmatrix("Narma_target1.csv");
output(:,1) = readmatrix("outputTR.csv");

DeepOutput(:,1) = readmatrix("DeepESN_output2.csv");

target_washout(:,1) = target(washout+1:end, :);


% wash_out = 100;
% input_data = input(wash_out+1:2000, 1);
% target_data = target(wash_out+1:2000, 1);
% output_data = output(wash_out+1:2000, 1);

%++++++++++++
% num_series = size(target_washout, 1);
% NRMSE = zeros(1, num_series);
% 
% for i = 1:num_series
%     % first get the raw error
%     e = (DeepOutput(i, :) - target_washout(i, :));
% 
%     % now get MSE
%     MSE = mean(e.^2);
% 
%     % now get NMSE
%     % NMSE = MSE./var(target_washout(i, :));
% 
%     var_target = var(target_washout);
% 
%     % now get RNMSE
%     % RNMSE(i, :) = sqrt(NMSE(i, :));
% 
%     % NRMSE
%     % NRMSE(i, :) = sqrt(MSE(i, :))./(max(target_washout(i, :))-min(target_washout(i, :)));
% 
%     NRMSE(i) = sqrt(MSE / var_target);
% 
% end
% 
% plot(NRMSE);
% title("NRMSE Plot for Output and Target")
% legend('NRMSE')
% xlabel('Time Series');
% ylabel('NRMSE');
% 
% % visLen = 200;
% % offset = 100;
% % timeidx = [1:visLen]+offset;

%++++++++++++

%+++==============
% px = 1; py=2; %subplot
% subplot(py,px,1)
% % plot(input(timeidx,:))        
% plot(input(timeidx,:))
% title('input')
% subplot(py,px,2) 
plot([DeepOutput target_washout])
title('output'); legend('output','target');
% plot([output(timeidx,:) target(timeidx+3000,:)])
% % plot([output_data(timeidx,:) target_data(timeidx+2000,:)])
% title('output'); legend('output','target');
%+++==============

% plot([DeepOutput target_washout])
% title('output'); legend('output','target');

