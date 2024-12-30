function [power_fuelcell, power_electrolyser, power_battery, power_grid, SOC, n_h2_fuelcell, n_h2_electrolyser, tank_pressure] = ...
    maximize_battery_usage_function(power_net, power_battery, power_fuelcell, power_electrolyser, power_grid, tank_pressure, SOC, n_h2_fuelcell, n_h2_electrolyser, current_data, voltage_data, SOC_min, SOC_max, SOC_low, SOC_high, tank_pressure_min, tank_pressure_max)
    %there is something wrong with figure 17b. So we have to do some
    %guesswork for hydrogen 

    % Calculate tank pressure based on the previous pressure and hydrogen inputs/outputs
    tank_pressure = tank_pressure_function(n_h2_electrolyser, n_h2_fuelcell, tank_pressure);
            

    if power_net <= 0 % Deficit in power
        if SOC <= SOC_low % Low SOC, avoid using battery
            power_battery = 0;
            if tank_pressure < tank_pressure_min % Low tank level, get power from the grid
                power_fuelcell = 0;
                power_electrolyser = 0;
                power_grid = power_net; % Grid supplies the deficit
            else
                power_fuelcell = power_net; % Fuel cell supplies the deficit
                n_h2_fuelcell = fuelcell_function(power_fuelcell); % Calculate moles of H2 from fuel cell
                power_electrolyser = 0;
            end
            
        else  % SOC > SOC_low, Sufficient SOC, use battery
            power_battery = power_net; % Battery supplies the deficit
            [SOC, power_battery] = battery_charge_discharge_function(power_battery, SOC);
            power_fuelcell = 0;
            power_electrolyser = 0;
            power_grid = 0;
        end
    
    else % Surplus in power
        if SOC < SOC_max % Not fully charged battery, charge it
            power_battery = power_net; % Battery absorbs the surplus
            [SOC, power_battery] = battery_charge_discharge_function(power_battery, SOC);
            power_electrolyser = 0;
            power_fuelcell = 0;
            power_grid = 0;
        else % SOC > SOC_max
            power_battery = 0;
            
            if tank_pressure < tank_pressure_max % Low tank level, use electrolyzer to store energy
                power_electrolyser = power_net; % Electrolyzer absorbs the surplus
                n_h2_electrolyser = electrolyser_function(power_electrolyser, current_data, voltage_data); % Calculate H2 from electrolyzer
                power_fuelcell = 0;
            else  % tank_pressure >= tank_pressure_max, High tank level, send surplus to the grid
                power_electrolyser = 0;
                power_grid = power_net; % Grid absorbs the surplus
            end
        end
    end
end