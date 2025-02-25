clear all

pmAddress_1 = 'USB0::0x1313::0x8078::P0013253::INSTR';
PM100D_1 = visadev(pmAddress_1);
%%

% Laser Stability Test: Collect power data over time
% Ask the user for sampling parameters
sample_interval = input('Enter the sampling interval (in seconds): ');
total_duration = input('Enter the total measurement duration (in seconds): ');

% Calculate number of samples (using floor to avoid overshooting the total time)
num_samples = floor(total_duration / sample_interval);

% Initialize arrays for storing time and power readings
time_values = zeros(1, num_samples);
power_values = zeros(1, num_samples);

fprintf('Starting laser stability measurement...\n');

% Start measurement loop
for ii = 1:num_samples
    % Record elapsed time (in seconds)
    current_time = (ii-1) * sample_interval;
    time_values(ii) = current_time;
    
    % Read power meter value
    power = PMreading(PM100D_1); % Read power value in mW
    
    % Save power reading
    power_values(ii) = power;
    
    % Display the stored values for this sample
    fprintf('Time = %.2f s, Power = %.6f mW\n', current_time, power);
    
    % Pause for the specified sampling interval (except after the last measurement)
    if ii < num_samples
        pause(sample_interval);
    end
end

% Calculate statistics
avg_power = mean(power_values);
std_power = std(power_values);
max_fluctuation = max(power_values) - min(power_values);

% Save results in a MAT file
save('LaserStabilityData.mat', 'time_values', 'power_values', 'avg_power', 'std_power', 'max_fluctuation');
disp('Data saved in LaserStabilityData.mat');

% Plot the stability data
figure;
plot(time_values, power_values, '-o', 'LineWidth', 1.5);
xlabel('Time (s)');
ylabel('Power (mW)');

% Create a title that includes the computed statistics
title_str = sprintf(['Laser Polarization Stability Measurement\n' ...
                     'Average: %.3f mW, Std Dev: %.3f mW, Max Fluctuation: %.3f mW'], ...
                     avg_power, std_power, max_fluctuation);
title(title_str);
grid on

%% Power meter reading function
function y = PMreading(PM100D_1)
    % Set wavelength and units
    fprintf(PM100D_1, 'SENS:CORR:WAV %d', 1550); % set wavelength in nm
    fprintf(PM100D_1, 'SENS:POW:UNIT W');         % set unit to Watts
    
    % Average multiple samples for a stable reading
    N_smp = 10;
    power_samples = zeros(1, N_smp);
    for jj = 1:N_smp
       power_samples(jj) = str2double(query(PM100D_1, 'READ?')); % Read power in Watts
    end
    power = sum(power_samples) / N_smp;
    
    % Convert power to milli-Watts and return
    y = power * 1e3; % power in mW
end
