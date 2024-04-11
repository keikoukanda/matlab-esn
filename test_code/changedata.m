% Step 1: CSVファイルからデータを読み込む
data = csvread('new_input_data.csv'); % 例えば、ファイル名が 'your_data.csv' の場合

% Step 2: データの形式を変更する（200x1を1x200に変更する）
data_transposed = data.'; % 転置することで行列の形式を変更

% Step 3: 新しいデータをCSVファイルに書き込む
writematrix(data_transposed, 'new_input_data1.csv'); % 新しいCSVファイルに書き込む
