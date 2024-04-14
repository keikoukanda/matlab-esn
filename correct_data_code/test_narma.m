
for i = 1:200
    % change random seed here
    randnum = rng(i);
    
    % set up lengeth of timeseries 
    timeLen = 6000;
    taut = 0;
    timeLen = timeLen + 2*taut;
    
    % create input data
    inputs.data = rand(2*timeLen,1)*0.5;
    
    % adjust input data. timeLen
    input = inputs.data(1:timeLen,1);
    % writematrix(input, 'input_data.csv');
    
    targets.data(i,:) = narmax(input,10,0);
    
end
writematrix(input, 'new_input_data.csv');
writematrix(targets.data(:,:), 'new_target_data.csv');
    
    function [o] = narmax(in,t,init) 
    % this will generate the narma output for input sequence in and the order
    % t.
        o = ones(size(in)).*init;
        
        for ni=t+1:size(in,1)
            o(ni,:) = 0.3.*o(ni-1,:) + 0.05.*o(ni-1,:).*sum(o(ni-t:ni-1,:))+...
                    1.5.*in(ni-t,:).*in(ni-1,:) + 0.1;
        end
    end

    
