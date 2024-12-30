function [SOC, power_battery, i_battery, voltage_battery] = battery_charge_discharge_function(power_battery, SOC)
% Given parameters
% power_net = 4000;
power_battery_divided = power_battery / 34; %divided by the total number of batteries
r_int = 0.0049;
v_oc = 12;
capacity_n = 100; % Nominal capacity
% SOC = 0.5; 

if power_battery_divided > 0
    a = 0.467;
    b = 1.898;
    k = -0.00276;
 
    % Define the equation as a function handle
    equation = @(i_battery_equation) v_oc - k * (capacity_n / (SOC + capacity_n * 0.1)) * i_battery_equation - ...
                 k * (capacity_n / (capacity_n - SOC)) * SOC  + ...
                 a * exp(b * SOC) + r_int * i_battery_equation;

else %power_battery <= 0
    a = 2.498;
    b = 2.679;
    k = 0.00857;

    % Define the equation as a function handle
    equation = @(i_battery_equation) v_oc - k * (capacity_n / (capacity_n - SOC)) * SOC - ...
               k * i_battery_equation * (capacity_n / (capacity_n - SOC)) - ...
               a * exp(-b * SOC) + r_int * i_battery_equation;

end

% Objective function for fsolve (find i_battery that satisfies power_battery = voltage_battery * i_battery)
objective = @(i_battery_equation) power_battery_divided - equation(i_battery_equation) * i_battery_equation;

% Initial guess for i_battery
initial_guess = 10;

% Solve for i_battery using fsolve
options = optimoptions('fsolve', 'Display', 'off'); % Suppress fsolve output
i_battery = fsolve(objective, initial_guess, options);

% Calculate the corresponding voltage_battery
voltage_battery = equation(i_battery);

SOC = SOC + i_battery/ capacity_n;

% Display the results
% fprintf('The current i_battery that satisfies the equation is: %.4f A\n', i_battery);
% fprintf('The corresponding voltage_battery is: %.4f V\n', voltage_battery);

end
