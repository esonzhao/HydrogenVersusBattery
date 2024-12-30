function n_h2_electrolyser = electrolyser_function(power_electrolyser, current_data, voltage_data)
   
% Given parameters
    n_el = 28;      % Number of electrolyser cells
    nF = 0.985;     % Faraday efficiency
    z = 2;          % Number of moles of electrons per mole of hydrogen
    F = 96485;      % Faraday constant

    if power_electrolyser == 0
        n_h2_electrolyser = 0;
    else
        % Interpolate to get the current corresponding to power_electrolyser
        i_electrolyser = interp1(voltage_data .* current_data, current_data, power_electrolyser, 'linear', 'extrap');

        % Interpolate to get the voltage corresponding to the calculated current
        v_electrolyser = interp1(current_data, voltage_data, i_electrolyser, 'linear', 'extrap');

        % Recalculate the current to ensure it is consistent with the voltage
        i_electrolyser = power_electrolyser / v_electrolyser;

        % Calculate the amount of hydrogen produced
        n_h2_electrolyser = nF * 3600 * ((n_el * i_electrolyser) / (z * F));    % x3600 for mol/s to mol/h

        disp(['Power Electrolyser: ', num2str(power_electrolyser)]);
        disp(['Interpolated Current: ', num2str(i_electrolyser)]);
        disp(['n_h2_electrolyser: ', num2str(n_h2_electrolyser)]);
    end
end
