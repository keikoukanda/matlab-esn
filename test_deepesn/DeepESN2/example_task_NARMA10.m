function task = example_task_NARMA10
    % NARMA-10タスクの例を作成する関数
    % このコードは、NARMA-10タスクのデータを読み込み、適切なTaskオブジェクトにそれらを設定します。

    task = Task(); % タスクを初期化
    task.set_name('NARMA10'); % タスクの名前を設定

    % NARMA-10の入力データとターゲットデータを生成する
    input_length = 10000; % データの長さ
    input_sequence = rand(input_length, 1); % 入力データをランダムに生成
    target_sequence = narmax(input_sequence, 10, 0); % NARMA10ターゲットを生成

    % データをタスクオブジェクトに設定
    task.set_data(input_sequence, target_sequence);

    % ホールドアウト交差検証のためのインデックスを設定
    % ここでは、適切なトレーニング、バリデーション、デザイン、テストのインデックスを指定します
    training_indices = 1:8000;
    validation_indices = 8001:9000;
    test_indices = 9001:10000;
    task.set_holdout_folds(training_indices, validation_indices, [], test_indices);
    

end
