factor = 20;
m = 2;
r = 0.2;
e = zeros(10, factor);
k = zeros(10, factor);
err = zeros(10, factor);
% figure;


% % ファイルのサイズでforのサイズを変更
% for v = 1:100
for layer = 1:10

    %      %import multiple file
    %%%=====各層のread-outをMSEかけてプロットする方=====%%%%
    %     input = readmatrix(append('x_output', num2str(v), '.csv'));
    %%%===============================================%%%%

    %%%------各層の状態をMSEかけた図を作成-----------%%%%%
    % scaling0.1
    % input(:,:) = readmatrix(fullfile('states/scaling01/', ['state_' num2str(layer) '.csv']));
    %scaling1
    input(:,:) = readmatrix(fullfile('states/scaling1/', ['1state_' num2str(layer) '.csv']));
    %input2(:,:) = readmatrix(append('afile', num2str(v), '.csv'));
    %%%---------------------------------------------%%%%%


    %     input = readmatrix("x_output.csv");

    %%=======各層のMSEの平均をとって出力========%%
    %%e=MSEを計算
    %     for n = 1:200
    %         e(n,:) = msentropy(input(n,:),m,r,factor);
    %     end
    %     k = mean(e,1);
    %     writematrix(k,append('k_MSE', num2str(v), '.csv'));
    %%=========================================%%

    %%-------各層のニューロンの平均をプロット,標準誤差を誤差棒に-------%%
    %     e(:,:) = msentropy(input(:,:),m,r,factor);
    for n = 1:10
        e(n,:) = msentropy(input(n,:),m,r,factor);
    end

    k(layer,:) = mean(e,1);
    err(layer,:) = std(e,1)/sqrt(10);

    %% visual 1
    % % plot-MSE-each-layer====
    % errorbar(1:20, k(layer,:), err(layer,:),'LineWidth',2);
    % title('scalling=1','FontSize',24)
    % hold on
    % % plot-MSE-each-layer====
end
%% visual 2 k(layer,factor)

max_values_per_column = max(k);
min_values_per_column = min(k);
max_value = max(max_values_per_column);
min_value = min(min_values_per_column);

for i = 1:20

    subplot(4,5,i)
    errorbar(1:10, k(:,i), err(:,i),'LineWidth',2);


    titename = append('scalefactor=',num2str(i));
    title(titename,'FontSize',15)
    ylim([min_value max_value])
    xlim([1 10])
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









% %%-----"%%==%%"を実行するときはコメントアウト----------%%
%% visual 1
% h_axes = gca;
% h_axes.XAxis.FontSize = 25;
% h_axes.YAxis.FontSize = 25;
% % ylabel を作成
% ylabel('SampEn','FontSize',24);
% xlabel('Scalefactor','FontSize',24);
% legend('layer = 1','layer = 2','layer = 3','layer = 4','layer = 5', ...
%     'layer = 6','layer = 7','layer = 8','layer = 9','layer = 10','FontSize',20)
% pbaspect([1 1 1])
% grid on
%%%-----"%%==%%"を実行するときはコメントアウト----------%%

%% -====================
% % 指定した変数を初期化
% vars = {'e','k','err'};
% clear(vars{:})
% % subplotするためにもう一回回した
% 
% for v= 1:10
%     input2(:,:) = readmatrix(append('afile', num2str(v), '.csv'));
% 
% 
%     for n = 1:10
%         e(n,:) = msentropy(input2(n,:),m,r,factor);
%     end
% 
% %     subplot(1,2,1)
% %     k = mean(e,1);
% %     err = std(e,1)/sqrt(10);
% %     
% %     errorbar([1:20], k, err);
% 
%     subplot(1,2,2)
%     k = mean(e,1);
%     err = std(e,1)/sqrt(10);
% 
%     errorbar(1:20, k, err);
%     title('scalling=0.1','FontSize',15)
%     hold on
% %         
% %     plot(1:20,k)
% % %     figure;
% end
%%% -====================
%%
% %%-----"%%==%%"を実行するときはコメントアウト----------%%
% h_axes = gca;
% h_axes.XAxis.FontSize = 20;
% h_axes.YAxis.FontSize = 20;     %全体のサイズ
% % ylabel を作成
% ylabel('SampEn','FontSize',24);
% % xlabel を作成
% xlabel('Scalefactor','FontSize',24);
% legend('1','2','3','4','5','6','7','8','9','10') %凡例
% pbaspect([1 1 1])               %protの比率を1:1
% %%----------------------------------------------------%%
% % plot(1:20,k(1,))
% % figure;
clear

function e = msentropy(input,m,r,factor)

    y=input;
    y=y-mean(y);
    y=y/std(y);
    
    for i=1:factor
       s=coarsegraining(y,i);
       sampe=sampenc(s,m+1,r );
       ...;
       e(i)=sampe(m+1);
    end
    e=e';
end