% Call generateTrainingData function
generateWarmupPeriod = 100; % Define the warm-up period
generatePeriod = 500; % Define the total period
initialCondition = zeros(2, 1); % Define the initial condition
[trainingData, teachingData] = generateTrainingData(generateWarmupPeriod, generatePeriod, initialCondition);

function [trainingData, teachingData] = generateTrainingData(generateWarmupPeriod, generatePeriod, initialCondition)
    dt = 0.1; % Example value for dt, replace with actual value
    dim = 2; % Example value for dim, replace with actual value
    generatedAllTimeSeries = NaN(dim, generateWarmupPeriod + generatePeriod);

    % Generate the time series
    odeOptions = odeset('RelTol',1e-6,'AbsTol',1e-9); % Adjust integration tolerances
    [t_axis, x_axis] = ode45(@(t,x) odefun(t,x), [0 dt], initialCondition, odeOptions);
    generatedAllTimeSeries(:,1) = x_axis(end,:).'; % Use end to get the last row

    % Add random noise
    noise_level = 0.1; % Example noise level, adjust as needed
    noise = noise_level * randn(dim, generateWarmupPeriod + generatePeriod);
    generatedAllTimeSeries = generatedAllTimeSeries + noise;

    for t = 2:generateWarmupPeriod + generatePeriod
        [t_axis, x_axis] = ode45(@(t,x) odefun(t,x), [(t-1)*dt t*dt], generatedAllTimeSeries(:,t-1), odeOptions);
        generatedAllTimeSeries(:,t) = x_axis(end,:).'; % Use end to get the last row
    end

    % Extract training data and teaching data
    trainingData = generatedAllTimeSeries(:, 1:generateWarmupPeriod);
    teachingData = generatedAllTimeSeries(:, generateWarmupPeriod+1:end);

    % Define the ODE function
    function [dxdt] = odefun(t, x)
        % Define the derivative functions
        dx1dt = x(2)^2 + t; % Example derivative function for x1
        dx2dt = -x(1) + 2*t; % Example derivative function for x2
        dxdt = [dx1dt; dx2dt];
    end
end
