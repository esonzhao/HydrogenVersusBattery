% Load wind speed data from Excel file with original headers preserved
filename = 'ferrario_2020_weather_inputs.xlsx';
wind_speed = readtable(filename, 'Sheet', 'wind_speed', 'VariableNamingRule', 'preserve');

% Extract wind speed data
v = wind_speed{:, 2}; % Assuming wind speed data is in the second column

% Parameters from the datasheet (Figure 5b)
power_nom = 2500;   % Nominal power (W), according to the paper it's 3000, but the specsheet says 2500.
v_cutin = 2;    % Cut-in wind speed (m/s)
v_midrange1 = 3;
v_midrange2 = 5; 
v_nom = 12;     % Nominal wind speed (m/s)
v_cutoff = 15;  % Cut-off wind speed (m/s)


%HOW TO CALCULATE FORMULA
% 1. Go to E30pro datasheet: https://www.enair.es/en/small-wind-turbines/e30pro
% 2. graph power output vs wind speed for v = 2 to 5, and v = 5 to 12 in excel.
% 3. Obtain equations for each graph. No needcto apply efficiency factors as ...
% we assume a manufacturer's power curve have them already applied 

% a fifth-order polynomial is derived from the graph, but it's
% computationally heavy: y = 0.2026 * v.^5 - 7.0783 * v.^4 + 86.689 * v.^3 - 425.89 * v.^2 + 927.09 * v - 741.77
% so I've decided to split the equation in 3 parts: v = 2 to 3, v = 3 to 5, and v = 5 onwards.

%equation from v = 2 to 3 m/s
equation1 = @(v) 10 * v - 20;

% equation from 3 to 5m/s
equation2 = @(v) (55* v.^2 - 295 * v + 400);

%equation from 5m/s until 12
equation3 = @(v) (-4.3733 * v.^3 + 92.196 * v.^2 - 253.58 * v - 199.29);


% Initialize the power output array
p_wt = zeros(size(v));

% Calculate the power output for each wind speed
for i = 1:length(v)
    if v(i) <= v_cutin
        p_wt(i) = 0; 
    elseif v(i) > v_cutin && v(i) < v_midrange1
        p_wt(i) = equation1(v(i));
    elseif v(i) >= v_midrange1 && v(i) < v_midrange2
        p_wt(i) = equation2(v(i));
    elseif v(i) >= v_midrange2 && v(i) < v_nom
        p_wt(i) = equation3(v(i));
    elseif v(i) >= v_nom && v(i) < v_cutoff
         p_wt(i) = power_nom;
    else 
        p_wt(i) = 0;
    end
end


% % Plot the wind speed (v)
% figure;
% subplot(2,1,1); % First subplot for wind speed
% plot(1:length(v), v);
% xlabel('Hour');
% ylabel('Wind Speed (m/s)');
% title('Wind Speed over 8760 Hours');
% grid on;
% 
% % Plot the wind turbine power output (p_wt)
% subplot(2,1,2); % Second subplot for wind turbine power output
% plot(1:length(p_wt), p_wt);
% xlabel('Hour');
% ylabel('Power Output (W)');
% title('Wind Turbine Power Output over 8760 Hours');
% grid on;


