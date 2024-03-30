% Define parameters
generateWarmupPeriod = 100; % Define the warm-up period
generatePeriod = 500; % Define the total period
initialCondition = zeros(2, 1); % Define the initial condition

% Call generateTrainingData function
[trainingData, teachingData] = generateTrainingData(generateWarmupPeriod, generatePeriod, initialCondition);

% Now you can use trainingData and teachingData for your RNN model

function [inputData, targetData] = generateTrainingData(generateWarmupPeriod, generatePeriod, initialCondition)
    % Initialize the time series
    dt = 0.1; % Example value for dt, replace with actual value
    dim = 2; % Example value for dim, replace with actual value
    generatedAllTimeSeries = NaN(dim, generateWarmupPeriod + generatePeriod);

    % Generate the time series
    [t_axis, x_axis] = ode45(@(t,x) odefun(t,x), [0 dt], initialCondition);
    generatedAllTimeSeries(:,1) = x_axis(end,:).'; % Use end to get the last row

    % Add random noise
    noise_level = 0.1; % Example noise level, adjust as needed
    noise = noise_level * randn(dim, generateWarmupPeriod + generatePeriod);
    generatedAllTimeSeries = generatedAllTimeSeries + noise;

    for t = 2:generateWarmupPeriod + generatePeriod
        [t_axis, x_axis] = ode45(@(t,x) odefun(t,x), [(t-1)*dt t*dt], generatedAllTimeSeries(:,t-1));
        generatedAllTimeSeries(:,t) = x_axis(end,:).'; % Use end to get the last row
    end

    % Extract training data and teaching data
    inputData = generatedAllTimeSeries(:, 1:generateWarmupPeriod);
    targetData = generatedAllTimeSeries(:, generateWarmupPeriod+1:end);

    % Output the training and teaching data
    disp('Input Data:');
    disp(inputData);
    disp('Target Data:');
    disp(targetData);

    % Define the ODE function
    function [dxdt] = odefun(t, x)
        % Set the parameters
        D = {@(t, x) f1(t, x(1), x(2));  % Derivative function for x1
             @(t, x) f2(t, x(1), x(2))}; % Derivative function for x2

        % Initialize the derivative vector
        dxdt = NaN(dim, 1);

        % Compute the derivative vector
        for d = 1:dim
            dxdt(d) = D{d}(t, x);
        end
    end
end


% Define the derivative functions
function dx1dt = f1(t, x1, x2)
    % Define the derivative function for x1
    % Example: dx1/dt = x2^2 + t
    dx1dt = x2^2 + t;
end

function dx2dt = f2(t, x1, x2)
    % Define the derivative function for x2
    % Example: dx2/dt = -x1 + 2*t
    dx2dt = -x1 + 2*t;
end
