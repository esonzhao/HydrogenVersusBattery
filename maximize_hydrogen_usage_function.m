function [power_fuelcell, power_electrolyser, power_battery, power_grid, SOC, n_h2_fuelcell, n_h2_electrolyser, tank_pressure] = ...
    maximize_hydrogen_usage_function(power_net, power_battery, power_fuelcell, power_electrolyser, power_grid, tank_pressure, SOC, n_h2_fuelcell, n_h2_electrolyser, current_data, voltage_data, SOC_min, SOC_max, SOC_low, SOC_high, tank_pressure_min, tank_pressure_max)
    
    %hysteresis is only really used in battery priority, not here in
    %hydrogen priority. Hence no SOC_low and SOC_high inputs.

    % Calculate tank pressure based on the previous pressure and hydrogen inputs/outputs
    tank_pressure = tank_pressure_function(n_h2_electrolyser, n_h2_fuelcell, tank_pressure);


    %no need to re-call tank_pressure after each logic because the main file already does that
    if power_net <= 0 % Deficit in power
        if tank_pressure <= tank_pressure_min % Low tank level, avoid using fuel cell and electrolyzer
            power_battery = 0;
            power_fuelcell = 0;
            power_electrolyser = 0;
            power_grid = 0;
            if SOC <= SOC_min % Very low SOC, avoid using battery
                power_grid = power_net; % Grid supplies the deficit
            else  % SOC > SOC_min, High SOC, use battery       
                power_battery = power_net; % Battery supplies the deficit 
                [SOC, power_battery] = battery_charge_discharge_function(power_battery, SOC);

            end

        else % tank_pressure > tank_pressure_min, Moderate tank level, use fuel cell
            power_fuelcell = power_net; % Fuel cell supplies the deficit
            n_h2_fuelcell = fuelcell_function(power_fuelcell); % Calculate moles of H2 from fuel cell
            power_electrolyser = 0;
            power_battery = 0;
            power_grid = 0;
        end

    else % Surplus in power
        if tank_pressure < tank_pressure_max % Tank not full, use electrolyzer
            power_electrolyser = power_net; % Electrolyzer absorbs the surplus
            n_h2_electrolyser = electrolyser_function(power_electrolyser, current_data, voltage_data); % Calculate H2 from electrolyzer
            power_fuelcell = 0;
            power_battery = 0;
            power_grid = 0;

        else  % tank_pressure >= tank_pressure_max, Tank full
            power_electrolyser = 0;
            power_fuelcell = 0;

            if SOC < SOC_max % Battery not full, charge battery
                power_battery = power_net; % Battery absorbs the surplus
                [SOC, power_battery] = battery_charge_discharge_function(power_battery, SOC);
                power_grid = 0;

            else  % SOC >= SOC_max, Battery full, send surplus to grid %maxed out at 0.8 
                power_battery = 0;
                power_grid = power_net; % Grid absorbs the surplus
            end
        end
   
    end
