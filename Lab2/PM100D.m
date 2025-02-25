clear all

pmAddress_1 = 'USB0::0x1313::0x8078::P0013253::INSTR';
PM100D_1 = visadev(pmAddress_1);
%%

% Initialize arrays for storing angle and power readings
angle_values = [];
power_values = [];

% Start manual input loop
while true
    % Prompt user for angle input
    angle = input('Enter the angle (0 to 360, or type "exit" to stop): ', 's');
    
    % Check if the user wants to exit
    if strcmpi(angle, 'exit')
        break; % Exit the loop
    end
    
    % Convert the input to a numeric value
    angle = str2double(angle);
    
    % Validate input (must be numeric and within 0-360 range)
    if isnan(angle) || angle < 0 || angle > 360
        disp('Invalid input! Please enter a number between 0 and 360.');
        continue; % Skip to next loop iteration
    end
    
    % Save the angle
    angle_values = [angle_values, angle*pi/180];

    % Read power meter value
    power = PMreading(PM100D_1); % Read power value

    % Save power reading
    power_values = [power_values, power];

    % Display the stored values
    fprintf('Saved: Angle = %.2f°, Power = %.6f W\n', angle, power);
end
angle_values
% Save results in a MAT file
save('PowerMeasurementData_otrolado.mat', 'angle_values', 'power_values');

% Display final message
disp('Data saved in PowerMeasurementData.mat');


polarplot(angle_values,power_values)

%%
function y=PMreading(PM100D_1)
    %  PM100D_1 = visa('ni',pmAddress_1);
    %fopen(PM100D_1);
    %fprintf(PM100D_1,'SENS:POW:REF %d',0.0); % set reference level
    fprintf(PM100D_1,'SENS:CORR:WAV %d',1550); % set WL in nm
    fprintf(PM100D_1,'SENS:POW:UNIT W'); % set nW 

    %fprintf(PM100D_1,'SENS:CORR:BEAM %d',4.5); % set beam size in mm
    N_smp=10;
    power_SFG=zeros(1,N_smp);
    for jj=1:N_smp
       power_SFG(jj)=str2double(query(PM100D_1,'READ?')); % read the power in W
    end
    %    power=str2double(query(PM100D_1,'READ?')); % read the power in W
    power=sum(power_SFG)./N_smp; 
    %y=power*10^9; % read power in micro-W
    y=power*10^3; % read power in milli-W
end
