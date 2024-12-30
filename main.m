clc; clear;

%% Define strategy
strategy = 1; % Set strategy (1 for maximizing hydrogen usage, 0 for maximizing battery usage)

%% Define the results folder
results_folder = 'results';

%% Define variables & constraints
hour = 8760; % Number of time steps:  730 = 1 month, 8760 = 1 year, 24 = 1 month. t = 1 is 12am, t = 8760 is 23:00.
tank_pressure = zeros(1, hour);
tank_pressure_min = 1;  %bar
tank_pressure_max = 30; %bar
tank_pressure(1) = 23;
SOC = zeros(1, hour);
SOC_min = 0.2; % minimum battery state of charge
SOC_max = 0.8;
SOC_low = 0.3;
SOC_high = 0.7;
SOC(1) = 0.5; % battery state of charge at t=1
i_battery = zeros(1, hour); %initialise battery current
power_net = zeros(1, hour); %initialise net power (generation minus load)
capacity_n = 100;
n_h2_electrolyser = zeros(1, hour);
n_h2_fuelcell = zeros(1, hour);

%% Initialize counters for grid power losses
power_loss_count = 0;
cumulative_power_loss = 0;
excess_power_count = 0;
cumulative_power_excess = 0;

%% Load the lookup table from Excel
filename = 'lookup_table_electrolyser.xlsx';
lookup_table_electrolyser = readtable(filename);
current_data = lookup_table_electrolyser.Current_A; % Extract current data from the table
voltage_data = lookup_table_electrolyser.Voltage_V; % Extract voltage data from the table

%% Initialize output variables
power_fuelcell = zeros(1, hour);  % Fuel cell power
power_electrolyser = zeros(1, hour);  % Electrolyzer power
power_battery = zeros(1, hour); % Battery power
power_grid = zeros(1, hour); % Grid power
output_data = zeros(hour, 10); % Include an additional column for tank_pressure

% Loop over hours 2 to max_num (modify as needed)
for t = 2:hour
    disp(t);
  
    if strategy == 1
        power_net(t) = calculate_power_net_function(t);
        % Call maximize_hydrogen_usage_function with the necessary inputs
        [power_fuelcell(t), power_electrolyser(t), power_battery(t), power_grid(t), SOC(t), n_h2_fuelcell(t), n_h2_electrolyser(t), ...
            tank_pressure(t)] = ...
            maximize_hydrogen_usage_function(power_net(t), power_battery(t), power_fuelcell(t), power_electrolyser(t), power_grid(t), tank_pressure(t-1), ...
            SOC(t-1), n_h2_fuelcell(t), n_h2_electrolyser(t), current_data, voltage_data, SOC_min, SOC_max, SOC_low, SOC_high, tank_pressure_min, tank_pressure_max);
    else
        power_net(t) = calculate_power_net_function(t);
        %battery priority
        [power_fuelcell(t), power_electrolyser(t), power_battery(t), power_grid(t), SOC(t), n_h2_fuelcell(t), n_h2_electrolyser(t), ...
            tank_pressure(t)] =  ...
         maximize_battery_usage_function(power_net(t), power_battery(t), power_fuelcell(t), power_electrolyser(t), power_grid(t), tank_pressure(t-1), ...
            SOC(t-1), n_h2_fuelcell(t), n_h2_electrolyser(t), current_data, voltage_data, SOC_min, SOC_max, SOC_low, SOC_high, tank_pressure_min, tank_pressure_max);
    end

        % Check if power_net is negative and assign to power_grid
    if power_net(t) < 0 && power_grid(t) == power_net(t)
            power_loss_count = power_loss_count + 1;
            cumulative_power_loss = cumulative_power_loss + power_net(t);
    elseif power_net(t) > 0 && power_grid(t) == power_net(t)
            excess_power_count = excess_power_count + 1;
            cumulative_power_excess = cumulative_power_excess + power_net(t);
    end
        
        % Ensure hydrogen values reset if no change
    if n_h2_fuelcell(t) == n_h2_fuelcell(t-1)   
            n_h2_fuelcell(t) = 0;
    elseif n_h2_electrolyser(t) == n_h2_electrolyser(t-1)
            n_h2_electrolyser(t) = 0;
    end

    % Update tank pressure based on the latest n_h2 values
    tank_pressure(t) = tank_pressure_function(n_h2_fuelcell(t), n_h2_electrolyser(t), tank_pressure(t-1));  
        
    % Store the results in the output_data matrix, including tank_pressure
    output_data(t, :) = [t, power_net(t), power_fuelcell(t), n_h2_fuelcell(t), power_electrolyser(t), n_h2_electrolyser(t), tank_pressure(t), power_battery(t), SOC(t), power_grid(t)];
                 

    % end
    if strategy == 1
        final_output_table = array2table(output_data, 'VariableNames', ...
        {'TimeStep', 'PowerNet', 'PowerFuelCell', 'n_h2_FuelCell', 'PowerElectrolyser', 'n_h2_Electrolyser', 'TankPressure', 'PowerBattery', 'SOC', 'power_grid'});
    
        final_output_filename = fullfile(results_folder, 'hydrogen_priority.xlsx');
        writetable(final_output_table, final_output_filename);
        disp(['Final output data saved to ', final_output_filename]);
    else
        final_output_table = array2table(output_data, 'VariableNames', ...
        {'TimeStep', 'PowerNet', 'PowerFuelCell', 'n_h2_FuelCell', 'PowerElectrolyser', 'n_h2_Electrolyser', 'TankPressure', 'PowerBattery', 'SOC', 'power_grid'});
    
        final_output_filename = fullfile(results_folder, 'battery_priority.xlsx');
        writetable(final_output_table, final_output_filename);
        disp(['Final output data saved to ', final_output_filename]);
    end

end

%% Graphs & displays
% Display grid power loss statistics
disp(['Number of hours the grid supplied the load: ', num2str(power_loss_count)]);
disp(['Cumulative power loss: ', num2str(cumulative_power_loss)]);
disp(['Number of hours the system was in excess: ', num2str(excess_power_count)]);
disp(['Cumulative power excess: ', num2str(cumulative_power_excess)]);

% Plotting the results
figure;

% Plot Power Balance
subplot(3,1,1);
plot(1:hour, power_electrolyser, '-b', 1:hour, power_fuelcell, '-r', 1:hour, power_battery, '-y', 1:hour, power_grid, '-m');
title('Power balance');
xlabel('Time (hours)');
ylabel('Power (W)');
legend('P_{el}', 'P_{fc}', 'P_{batt}', 'P_{grid}');
ylim([-10000 10000]); % Set y-axis limits for Power Balance
grid on;

% Plot SOC
subplot(3,1,2);
plot(1:hour, SOC, '-b');
title('SOC');
xlabel('Time (hours)');
ylabel('State of Charge (SOC)');
legend('SOC');
ylim([-0.1 1.1]); % Set y-axis limits for SOC with room on each end
grid on;

% Plot Tank Pressure
subplot(3,1,3);
plot(1:hour, tank_pressure, '-b');
title('Tank Pressure');
xlabel('Time (hours)');
ylabel('Pressure (bar)');
legend('p_{tank}');
ylim([-1 31]); % Set y-axis limits for Tank Pressure with room on each end
grid on;