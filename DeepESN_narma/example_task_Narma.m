function task = example_task_Narma

task = Task(); %initialize the task
task.set_name('Narma10'); %set the name
input_data = readmatrix('input_narma10.csv'); %read the input data
target_data = readmatrix('target_narma10.csv'); %read the taregt data (i.e. the delayed versions of the input in this case)
task.set_data(input_data,target_data); %set the input and target data for the task
task.set_holdout_folds(1:4000, 4001:5000, 1:5000, 5001:6000); %set the indices for training/validation/design/test
                                                              %for hold-out cross validation