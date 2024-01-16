
%% Load text files, extract location data from raw char arrays

fileIDNE = fopen("dur01d_ams_na14v10.txt", "r"); % open file for reading 
fileIDOH = fopen("dur01d_ams_na14v2.txt", "r");
raw = [fscanf(fileIDNE, "%c"), fscanf(fileIDOH, "%c")];

rexprNames = "(?<=(\d{2}-\d{4}\s))[\d\s\w-]+";
locNames = regexp(raw, rexprNames, "match");
locNames = strtrim(locNames); % remove leading and trailing whitespace

rexprCoords = "\d{1,2}\.\d{4}[\s]+(-)?\d{1,2}\.\d{4}";
locCoords = regexp(raw, rexprCoords, "match");

%% Convert lat/lon data to numeric

rexprLat = "^\d{1,2}\.\d{4}";
locLat = regexp(locCoords, rexprLat, "match");
locLat = str2double(vertcat(locLat{:}));

rexprLon = "(-)?\d{1,2}\.\d{4}$";
locLon = regexp(locCoords, rexprLon, "match");
locLon = str2double(vertcat(locLon{:}));
% some longitudes are positive (e.g., 79.1500) but should be negative.
isPos = locLon > 0; % Positive longitudes put us in Tibet.
locLon(isPos) = locLon(isPos).*-1;

coordMat = [locLat, locLon]; % combine lat and lon data in single matrix

%% Combine station names and coordinates in table, then export to excel

station_info = cell2table([locNames', num2cell(locLat), num2cell(locLon)],...
    "VariableNames", ["Name" "Lat" "Lon"]); % package as table

% v2 is Ohio river basin and surroundings, v10 is Northeast US
% see https://hdsc.nws.noaa.gov/pfds/pfds_series.html for data info
filename = 'Atlas14_station_info_v2v10.xlsx'; % name new excel file
writetable(station_info, filename, "Sheet", 1)






















%% Troubleshoot single-entry discrepancy between names and coords
% 3,530 coordinate pairs, 3,531 station names >:(
% TRI-CITIES AP (locNames{2069}) reading as TRI because I didn't include "-"
% in list of possible name characters - fixed, but not the issue...

% FIXED: 1113, blank coordinates, 0.0000; fixed with \d{2} --> \d{1,2}
% MONCURE, NC lists coordinates as (0.0000, 0.0000)
