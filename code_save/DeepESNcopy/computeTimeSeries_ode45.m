function generatedTimeSeries = computeTimeSeries_ode45(obj, generateWarmupPeriod, generatePeriod, initialCondition)
            % Initialize the time series
            dt=obj.timeSeriesParameters.dt;
            dim=obj.timeSeriesParameters.dim;
            generatedAllTimeSeries = NaN(dim, generateWarmupPeriod + generatePeriod);
            generatedTimeSeries = NaN(dim, generatePeriod);

            % Generate the time series
            [t_axis, x_axis] = ode45(@(t,x) odefun(t,x), [0 dt], initialCondition);
            generatedAllTimeSeries(:,1) = x_axis(size(t_axis,1),:).';

            for t=2:generateWarmupPeriod + generatePeriod
                [t_axis,x_axis] = ode45(@(t,x) odefun(t,x), [(t-1)*dt t*dt], generatedAllTimeSeries(:,t-1));
                generatedAllTimeSeries(:,t) = x_axis(size(t_axis,1),:).';
            end

            generatedTimeSeries = generatedAllTimeSeries(:,generateWarmupPeriod+1:end);
            

            % Define the ODE function
            function [dxdt] = odefun(t,x)
                % Set the parameters
                dim = obj.timeSeriesParameters.dim;
                D = obj.timeSeriesParameters.D;

                % Initialize the derivative vector
                dxdt=NaN(dim,1);
                
                % Compute the derivative vector
                for d=1:dim
                    dxdt(d)=D{d}(t,x);
                end
            end
        end