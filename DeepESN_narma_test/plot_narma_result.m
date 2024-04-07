

%% visualize

input(:,1) = readmatrix("Narma_input.csv");
target(:,1) = readmatrix("Narma_target.csv");
output(:,1) = readmatrix("outputTR.csv");


% wash_out = 100;
% input_data = input(wash_out+1:2000, 1);
% target_data = target(wash_out+1:2000, 1);
% output_data = output(wash_out+1:2000, 1);


 % % first get the raw error
 %    e = (output_data - target);
 % 
 %    % now get MSE
 %    MSE = mean(e.^2);
 % 
 %    % now get NMSE
 %    NMSE = MSE./var(target);
 % 
 %    % now get RNMSE
 %    RNMSE = sqrt(NMSE);
 % 
 %    % NRMSE
 %    NRMSE = sqrt(MSE)./(max(target)-min(target));
 % 
 % 
 %    plot(nrmse);

visLen = 200;
offset = 100;
timeidx = [1:visLen]+offset;

px = 1; py=2; %subplot
subplot(py,px,1)
% plot(input(timeidx,:))        
plot(input(timeidx,:))
title('input')
subplot(py,px,2) 
plot([output(timeidx,:) target(timeidx+3000,:)])
% plot([output_data(timeidx,:) target_data(timeidx+2000,:)])
title('output'); legend('output','target');
