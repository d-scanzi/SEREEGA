% labels = utl_get_montage(montage)
%
%       Returns a cell of predefined channel labels contained in the 
%       indicated electrode montage.
%
% In:
%       montage - name of the montage, or '?' for a list of available
%                 montages
%
% Out:
%       labels - cell of channel labels contained in the indicated montage,
%                or cell of montage names (in case of montage = '?')
%
% Usage example:
%       >> labels = utl_get_montage('S64');
%       >> lf = lf_generate_fromnyhead('labels', labels);
% 
%                    Copyright 2017 Laurens R Krol
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology

% 2018-04-23 lrk
%   - Added '?' montage, which returns a list of available montages
% 2018-01-09 lrk
%   - Added EASYCAP actiCAP 32/64 and BioSemi 32/64 montages.
% 2017-08-10 First version

% This file is part of Simulating Event-Related EEG Activity (SEREEGA).

% SEREEGA is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.

% SEREEGA is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.

% You should have received a copy of the GNU General Public License
% along with SEREEGA.  If not, see <http://www.gnu.org/licenses/>.

function labels = utl_get_montage(montage)

switch montage
    case '?'
        % return a list of all montages
        labels = {'actiCAP32', 'actiCAP64', 'BioSemi32', 'BioSemi64', ...
                  'S64'};
    case 'actiCAP32'
        % EASYCAP (Brain Products) Standard 32Ch actiCAP Electrode Cap
        labels = {'Fp1', 'Fz', 'F3', 'F7', 'FT9', 'FC5', 'FC1', 'C3', ...
                  'T7', 'TP9', 'CP5', 'CP1', 'Pz', 'P3', 'P7', 'O1', ...
                  'Oz', 'O2', 'P4', 'P8', 'TP10', 'CP6', 'CP2', 'Cz', ...
                  'C4', 'T8', 'FT10', 'FC6', 'FC2', 'F4', 'F8', 'Fp2'};
    case 'actiCAP64'
        % EASYCAP (Brain Products) Standard 64Ch actiCAP Electrode Cap
        labels = {'Fp1', 'Fz', 'F3', 'F7', 'FT9', 'FC5', 'FC1', 'C3', ...
                  'T7', 'TP9', 'CP5', 'CP1', 'Pz', 'P3', 'P7', 'O1', ...
                  'Oz', 'O2', 'P4', 'P8', 'TP10', 'CP6', 'CP2', 'Cz', ...
                  'C4', 'T8', 'FT10', 'FC6', 'FC2', 'F4', 'F8', 'Fp2', ...
                  'AF7', 'AF3', 'AFz', 'F1', 'F5', 'FT7', 'FC3', 'C1', ...
                  'C5', 'TP7', 'CP3', 'P1', 'P5', 'PO7', 'PO3', 'POz', ...
                  'PO4', 'PO8', 'P6', 'P2', 'CPz', 'CP4', 'TP8', 'C6', ...
                  'C2', 'FC4', 'FT8', 'F6', 'AF8', 'AF4', 'F2', 'Iz'};
    case 'BioSemi32'
        % BioSemi 32-channel 10/20 layout
        labels = {'Fp1', 'AF3', 'F7', 'F3', 'FC1', 'FC5', 'T7', 'C3', ...
                  'CP1', 'CP5', 'P7', 'P3', 'Pz', 'PO3', 'O1', 'Oz', ...
                  'O2', 'PO4', 'P4', 'P8', 'CP21', 'CP2', 'C4', 'T8', ...
                  'FC6', 'FC2', 'F4', 'F8', 'AF4', 'Fp2', 'Fz', 'Cz'}; 
    case 'BioSemi64'
        % BioSemi 64-channel 10/20 layout
        labels = {'Fp1', 'Fz', 'F3', 'F7', 'FC5', 'FC1', 'FCz', 'C3', ...
                  'T7', 'CP5', 'CP1', 'Pz', 'P3', 'P7', 'P9', 'O1', ...
                  'Oz', 'O2', 'P4', 'P8', 'P10', 'CP6', 'CP2', 'Cz', ...
                  'C4', 'T8', 'FC6', 'FC2', 'F4', 'F8', 'Fp2', 'Fpz', ...
                  'AF7', 'AF3', 'AFz', 'F1', 'F5', 'FT7', 'FC3', 'C1', ...
                  'C5', 'TP7', 'CP3', 'P1', 'P5', 'PO7', 'PO3', 'POz', ...
                  'PO4', 'PO8', 'P6', 'P2', 'CPz', 'CP4', 'TP8', 'C6', ...
                  'C2', 'FC4', 'FT8', 'F6', 'AF8', 'AF4', 'F2', 'Iz'};
    case 'S64'
        % SEREEGA-64: a selection of 64 EEG channels
        labels = {'Fp1', 'Fp2', 'AF7', 'AF3', 'AFz', 'AF4', 'AF8', ...
                  'F7', 'F5', 'F3', 'F1', 'Fz', 'F2', 'F4', 'F6', 'F8', ...
                  'FT7', 'FC5', 'FC3', 'FC1', 'FCz', 'FC2', 'FC4', ...
                  'FC6', 'FT8', 'T7', 'C5', 'C3', 'C1', 'Cz', 'C2', ...
                  'C4', 'C6', 'T8', 'P9', 'TP7', 'CP5', 'CP3', 'CP1', ...
                  'CPz', 'CP2', 'CP4', 'CP6', 'TP8', 'P10', 'P7', 'P5', ...
                  'P3', 'P1', 'Pz', 'P2', 'P4', 'P6', 'P8', 'PO9', ...
                  'PO7', 'PO3', 'POz', 'PO4', 'PO8', 'PO10', ...
                  'O1', 'Oz', 'O2'};
    otherwise
        warning('montage ''%s'' not found', montage);
        labels = '';
end

end