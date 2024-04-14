series_length = 6000;
narma_series = generate_narma10_series(series_length);

% Example: print the first 10 values of the generated series
writematrix(narma_series, 'target_narma10.csv')



function y = generate_narma10_series(length)
    % Parameters
    n = 10;
    alpha = 0.3;
    beta = 0.05;
    gamma = 1.5;
    delta = 0.1;

    % Initialize variables
    y = zeros(1, length);
    u = rand(1, length) * 0.1; % Adjust the input range

    writematrix(u, 'input_narma10.csv')

    for t = n+1:length
        y_sum = sum(y(t-n:t-1));  % Calculate the sum of past n elements of y

        % Calculate the next value of y
        y(t) = alpha * y(t-1) + beta * y_sum * y(t-1) + gamma * u(t-n) * y(t-n) + delta;
    end
end


