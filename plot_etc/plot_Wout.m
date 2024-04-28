Wout = readmatrix("Wout_MC.csv");

% woutの状態を見るためのプロットだけど，意味ないです

% Assuming your input data is stored in a variable called inputData

% Define the number of layers and neurons per layer
numLayers = 10;
neuronsPerLayer = 10;

% Initialize a cell array to store data for each layer
layerData = cell(4, numel([1 50 100 200]));
i = 1;
% Loop over each layer
for idx = [1 50 100 200]
    
    MCtau = idx;
    for layer = 1:numLayers
        % Calculate the indices corresponding to the neurons in this layer
        startNeuron = (layer - 1) * neuronsPerLayer + 1;
        endNeuron = layer * neuronsPerLayer;

        % Extract data for this layer
        layerData{i,layer} = Wout(MCtau, startNeuron:endNeuron);
    end
    i = i+1;
end

% 指定された idx（1 と 3）ごとにプロットする
idx_to_plot = [1,2,3,4];

% グラフの色を指定
colors = {'b', 'r', [0, 0.7, 0], [1, 0.5, 0]}; % g と y に近い色に変更

% 新しいフィギュアを作成
figure;

for layer = 1:numLayers
    % 新しい subplot を追加
    subplot(2, 5, layer);
    hold on;

    % 各 idx に対してプロット
    for i = 1:numel(idx_to_plot)
        idx = idx_to_plot(i);
        plot(layerData{idx,layer}, 'Color', colors{i},'LineWidth', 1.5);
    end

    xlim([1, 10]);
    hold off;

    % グラフの装飾
    xlabel('Neuron');
    ylabel('Value');
    title(['Layer ', num2str(layer)]);
    legend('MCtau = 1', 'MCtau = 50', 'MCtau = 100', 'MCtau = 200');
end

clear