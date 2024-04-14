% 各層の出力のMSE解析の結果を読み込み、標準誤差で20枚プロットする
% 

% [layer,tau,試行回数]
% 試行回数10
%ファイルの量
for v = 1:100
    input(v,:) = readmatrix(append('k_MSE', num2str(v), '.csv'));
end
% input_meに[layer,tau,試行回数]に対応したinputを代入
for v = 1:10
    input_me(:,:,v) = input((v-1)*10+1:(v*10),:);
end


% input_ave,3次元の平均
% err,input_meの標準誤差の計算
input_ave(:,:) = mean(input_me,3);
err(:,:) = std(input_me, [], 3)/sqrt(20);
% % % % writematrix(input_ave,"scaling0")
% for i = 1:20
%     figure;
% %     plot(1:10,mean(input(v,i)))
% 
%     errorbar([1:10], input_ave(:,i), err(:,i));
% %     ylim([0.4 2.5])
%     xlabel('layer')
%     ylabel('SampEn')
%     h_axes = gca;
%     h_axes.XAxis.FontSize = 15;
%     h_axes.YAxis.FontSize = 15;
% %     hold on
% %     errorbar([1:1:10] ,std(input, 1));
% %     errorbar([1:1:10] , mean(input,i), std(input, [] , 1)/sqrt() );
%     % errorbar([1:1:delays] , mean(d,2), std(d, [] , 2)/sqrt(repetitions) );
%     FileName = strrep(strrep(strcat('chart_13_CH',num2str(i),'.png'),':','_'),' ','_');
%     saveas(gcf,FileName);
%     
% end
figure;
for i = 1:20
    
%     plot(1:10,mean(input(v,i)))
    subplot(4,5,i)
    errorbar([1:10], input_ave(:,i), err(:,i));
    titename = append('scalefactor=',num2str(i));
    title(titename,'FontSize',15)
%     ylim([0.4 2.5])
    xlabel('layer')
    ylabel('SampEn')
    h_axes = gca;
    h_axes.XAxis.FontSize = 15;
    h_axes.YAxis.FontSize = 15;
%     hold on
%     errorbar([1:1:10] ,std(input, 1));
%     errorbar([1:1:10] , mean(input,i), std(input, [] , 1)/sqrt() );
    % errorbar([1:1:delays] , mean(d,2), std(d, [] , 2)/sqrt(repetitions) );
%     FileName = strrep(strrep(strcat('chart_13_CH',num2str(i),'.png'),':','_'),' ','_');
%     saveas(gcf,FileName);
    
end
% for i = 1:20
%     
% %     plot(1:10,mean(input(v,i)))
%     errorbar([1:10], input_ave(:,i), err(:,i));
%     titename = append('scalefactor=',num2str(i));
%     title(titename,'FontSize',15)
% %     ylim([0.4 2.5])
%     xlabel('layer')
%     ylabel('SampEn')
%     h_axes = gca;
%     h_axes.XAxis.FontSize = 15;
%     h_axes.YAxis.FontSize = 15;
% %     hold on
% %     errorbar([1:1:10] ,std(input, 1));
% %     errorbar([1:1:10] , mean(input,i), std(input, [] , 1)/sqrt() );
%     % errorbar([1:1:delays] , mean(d,2), std(d, [] , 2)/sqrt(repetitions) );
% %     FileName = strrep(strrep(strcat('chart_13_CH',num2str(i),'.png'),':','_'),' ','_');
% %     saveas(gcf,FileName);
%     
% end
% FileName = strrep(strrep(strcat('../result_matlab/iaaft/result/chart_13_CH’,num2str(ch),'.png'),‘:’,‘_’),' ’,’_‘);
% saveas(gcf,FileName);

% close all