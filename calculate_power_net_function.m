
function [power_net_t, p_res] = calculate_power_net_function(t)

    % Ensure the necessary functions are initialized
    solar_function; % Initializes p_pv
    wind_turbine_function; % Initializes p_wt. 
    load_assumptions_function; % Initializes p_load
    
    % Calculate net power and battery current
    p_res = p_pv + p_wt;
    power_net = p_res - p_load;

    % Return net power at the specified hour t
    power_net_t = power_net(t);


end
% % Plot p_res
% figure;
% subplot(2,1,1); % First subplot (top)
% plot(1:8760, p_res);
% xlabel('Hour');
% ylabel('p\_res (W)');
% title('Total Renewable Power Output (p\_res) Over 8760 Hours');
% grid on;
% 
% % Plot power_net
% subplot(2,1,2); % Second subplot (bottom)
% plot(1:8760, power_net_t);
% xlabel('Hour');
% ylabel('power\_net (W)');
% title('Net Power Output (power\_net) Over 8760 Hours');
% grid on;