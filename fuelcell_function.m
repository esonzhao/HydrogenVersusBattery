function [n_h2_fuelcell, I_fc_solution] = fuelcell_function(power_fuelcell)
    % Given parameters
    a_fc = 73.326;
    b_fc = -2.122;
    c_fc = 0.077;
    d_fc = -0.001;
    faraday_constant = 96485;
    fuelcell_units = 3; % Number of fuel cell units
    cells_per_unit = 80; % Number of fuel cells per unit (since we calculate for each)
    faraday_efficiency = 0.99;
    z = 2;
    
    abs_power_fuelcell = abs(power_fuelcell);
    
    if abs_power_fuelcell == 0
        n_h2_fuelcell = 0;  % Explicitly set n_h2_fuelcell to 0 when power_fuelcell is 0
    else
        % Distribute power_fuelcell equally among the three units
        power_fuelcell_per_unit = abs_power_fuelcell / fuelcell_units;

        % Solve the equation for I_fc using fsolve for each unit
        fun = @(I_fc) I_fc * (a_fc + b_fc * I_fc + c_fc * I_fc^2 + d_fc * I_fc^3) - power_fuelcell_per_unit;
        initial_guess = 10.59;  %we get this number iteratively, but it doesn't matter too much. It's this now cos it'll be faster to compute.
        I_fc_solution = fsolve(fun, initial_guess);
        %we can see that when power is 2000/3, it matches to figure 10.b
        %for current. The trajectory is on the same path.
        
        % Calculate hydrogen production for one unit
        n_h2_fuelcell_per_unit = faraday_efficiency * 3600 * ((cells_per_unit * I_fc_solution) / (z * faraday_constant)); % x3600 for mol/s to mol/h

        % Total hydrogen production is sum of all units
        n_h2_fuelcell = n_h2_fuelcell_per_unit * fuelcell_units;
    end
end
