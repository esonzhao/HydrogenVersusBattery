% Load radiation and temperature data from Excel file
filename = 'ferrario_2020_weather_inputs.xlsx';

% Load radiation and temperature data from Excel file with original headers
radiation = readtable(filename, 'Sheet', 'radiation', 'VariableNamingRule', 'preserve');
temperature = readtable(filename, 'Sheet', 'temperature', 'VariableNamingRule', 'preserve');


% Extract radiation and temperature data
G = radiation{:, 2}; % Assuming radiation data is in the second column
T = temperature{:, 2}; % Assuming temperature data is in the second column

% Ensure the lengths of G and T match the expected length of hours
hours = 1:8760;
assert(length(G) == length(hours), 'Radiation data length mismatch');
assert(length(T) == length(hours), 'Temperature data length mismatch');



% Initialize the PV power output array
p_pv = zeros(size(G));

% Calculate the PV power output for each hour
for i = 1:length(G)
    p_pv_mono(i) = moni_si(G(i), T(i));
    p_pv_poly(i) = poly_si(G(i), T(i));
    p_pv_thin(i) = thin_si(G(i), T(i));

    p_pv(i) = p_pv_mono(i) + p_pv_poly(i) + p_pv_thin(i);
    % Replace NaN with zero
    if isnan(p_pv(i))
        p_pv(i) = 0;
    end
    
    % Ensure non-negative PV power output
    if p_pv(i) < 0
        p_pv(i) = 0;
    end
    
end

% Plot the PV power output
% figure;
% plot(p_pv);
% xlabel('Time (hours)');
% ylabel('PV Power Output (kW)');
% title('PV Power Output Over Time');
% grid on;

% Function to calculate PV power output
function p_pv_mono = moni_si(G, T)
    Isc_stc = 8.75; % A (from datasheet)
    Voc_stc = 37.8; % V (from datasheet)
    alpha = -0.042 / 100; % %/°C to /°C
    beta = -0.323 / 100; % %/°C to /°C
    omega = -0.04; % additional parameter
    FF = 0.756; % (from datasheet)
    Ns = 20; % NORMALLY 20
    Np = 1; % number of panels in parallel
    n_totdc = 0.82; % total DC efficiency


    % Constants
    G_stc = 1000; % W/m^2, standard test conditions
    T_stc = 25; % °C, standard test conditions
    
    % Temperature correction
    dT = T - T_stc;
    
    % Current calculation
    Isc = Isc_stc * (G / G_stc) * (1 + alpha * dT);
    
    % Voltage calculation
    Voc = Voc_stc * (1 + beta * dT) * (1 + omega * (log(G / G_stc))^2);
    
    % PV power calculation
    p_pv_mono = Isc * Voc * FF * Ns * Np * n_totdc;
    % p_pv_mono = 0;
end

function p_pv_poly = poly_si(G, T)
    Isc_stc = 8.55; % A (from datasheet)
    Voc_stc = 36.72; % V (from datasheet)
    alpha = 0.04 / 100; % %/°C to /°C
    beta = -0.32 / 100; % %/°C to /°C
    omega = -0.04; % additional parameter
    FF = 0.735; % (from datasheet)
    Ns = 21; % number of panels in series
    Np = 1; % number of panels in parallel
    n_totdc = 0.85; % total DC efficiency

    % Constants
    G_stc = 1000; % W/m^2, standard test conditions
    T_stc = 25; % °C, standard test conditions
    
    % Temperature correction
    dT = T - T_stc;
    
    % Current calculation
    Isc = Isc_stc * (G / G_stc) * (1 + alpha * dT);
    
    % Voltage calculation
    Voc = Voc_stc * (1 + beta * dT) * (1 + omega * (log(G / G_stc))^2);
    
    % PV power calculation
    p_pv_poly = Isc * Voc * FF * Ns * Np * n_totdc;
    % p_pv_poly = 0;  %comment this if mono_si isn't the sole pv output
end

function p_pv_thin = thin_si(G, T)
    Isc_stc = 3.93; % A (from datasheet)
    Voc_stc = 40.9; % V (from datasheet)
    alpha = 0.08 / 100; % %/°C to /°C
    beta = -0.33 / 100; % %/°C to /°C
    omega = -0.04; % additional parameter
    FF = 0.621; % (from datasheet)
    Ns = 50; % number of panels in series
    Np = 1; % number of panels in parallel
    n_totdc = 0.87; % total DC efficiency


    % Constants
    G_stc = 1000; % W/m^2, standard test conditions
    T_stc = 25; % °C, standard test conditions
    
    % Temperature correction
    dT = T - T_stc;
    
    % Current calculation
    Isc = Isc_stc * (G / G_stc) * (1 + alpha * dT);
    
    % Voltage calculation
    Voc = Voc_stc * (1 + beta * dT) * (1 + omega * (log(G / G_stc))^2);
    
    % PV power calculation
    p_pv_thin = Isc * Voc * FF * Ns * Np * n_totdc;
    % p_pv_thin = 0;  %comment this if mono_si isn't the sole pv output
end

