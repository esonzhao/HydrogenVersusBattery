filename = 'ferrario_2020_weather_inputs.xlsx';
p_load = load_assumptions_data(filename);

% % % Plot Load Assumptions
% % figure;
% % plot(hours, p_load);
% % xlabel('Hours');
% % ylabel('Load Assumptions');
% % title('Load Assumptions Over Time');
% % grid on;

function p_load = load_assumptions_data(filename)
    % Read load assumptions data from Excel file
    load_assumptions = readtable(filename, 'Sheet', 'load_assumptions');
    
    % Check dimensions
    hours = 0:8759;
    assert(height(load_assumptions) == length(hours), 'Load assumptions data does not have 8760 rows');
    
    % Extract data
    p_load = load_assumptions{:, 2}; % Assuming load data is in the second column
    
    % Verify data length
    assert(length(p_load) == length(hours), 'Load data length mismatch');
end

%the load here is weird. Figure 19a gives the load profile. Spring and autumn
%k is 0.825 of winter, but the graph is actually 0.875. Summer k is
%indicated to be 1.125, but graph is actually 1.25 of winter. What the hell lmao. For now,
%we will go with the graph (0.875 & 1.25), but if load doesn't line up, go back to what's
%indicated in k.

% the paper makes a mistake. Figure 20 shows power balance. They assume
% that winter is 3 months, so from jan - march. However, there are only 2
% months of winter at the start of the year. 
