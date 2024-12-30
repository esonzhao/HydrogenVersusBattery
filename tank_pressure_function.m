function tank_pressure = tank_pressure_function(n_h2_electrolyser, n_h2_fuelcell, tank_pressure)
    % Define parameters
    R = 0.082;      % Universal gas constant (L·atm/(mol·K))
    T = 293;        % Temperature in Kelvin (20°C)
    V_geom_L = 1044; % Geometric volume of the tank in liters

    % Calculate the net molar variation in the tank (electrolyzer adds, fuel cell consumes)
    molar_variation = n_h2_fuelcell - n_h2_electrolyser;

    % Calculate the change in tank pressure based on the molar variation
    tank_p_change = molar_variation * R * T / V_geom_L;  %if positive, tank increases. If negative, tank decreases.

    % Update the tank pressure for the current time step
    tank_pressure = tank_pressure + tank_p_change;
end
