% h = erp_plot_signal_fromclass(class, epochs, varargin)
%
%       Plots an ERP class activation signal. In blue, solid line: the mean 
%       signal as defined. The dotted and dashed lines indicate the
%       signal's variability as per the defined deviations. If a slope has
%       been defined, the red curve indicates the signal (mean and
%       extremes) at the end of the slope (i.e. the final epoch).
%
% In:
%       class - 1x1 struct, the class variable
%       epochs - single epoch configuration struct containing at least
%                sampling rate (srate), epoch length (length), and total
%                number of epochs (n)
%
% Optional (key-value pairs):
%       newfig - (0|1) whether or not to open a new figure window.
%                default: 1
%       baseonly - (0|1) whether or not to plot only the base signal,
%                  without any deviations or sloping. default: 0
%
% Out:  
%       h - handle of the generated figure
%
% Usage example:
%       >> epochs.n = 100; epochs.srate = 500; epochs.length = 1000;
%       >> erp.peakLatency = 300; erp.peakLatencySlope = 150;
%       >> erp.peakWidth = 100; erp.peakWidthDv = 50;
%       >> erp.peakWidthSlope = 100; >> erp.peakAmplitude = 1;
%       >> erp.peakAmplitudeDv = .25; erp.peakAmplitudeSlope = -.25;
%       >> erp = utl_check_class(erp, 'type', 'erp')
%       >> plot_signal_fromclass(erp, epochs);
% 
%                    Copyright 2017 Laurens R Krol
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology

% 2017-06-13 First version

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

function h = erp_plot_signal_fromclass(class, epochs, varargin)

% parsing input
p = inputParser;

addRequired(p, 'class', @isstruct);
addRequired(p, 'epochs', @isstruct);

addParamValue(p, 'newfig', 1, @isnumeric);
addParamValue(p, 'baseonly', 0, @isnumeric);

parse(p, class, epochs, varargin{:})

class = p.Results.class;
epochs = p.Results.epochs;
newfig = p.Results.newfig;
baseonly = p.Results.baseonly;

% getting time stamps
x = 1:epochs.length/1000*epochs.srate;
x = x/epochs.srate;

% correcting time stamps if a prestimulus period is indicated
if isfield(epochs, 'prestim'),
    x = x - epochs.prestim/1000; end

if newfig, h = figure; else h = NaN; end
hold on;

% plotting the mean signal, no deviations applied
plot(x, erp_generate_signal( ...
        class.peakLatency, ...
        class.peakWidth, ...
        class.peakAmplitude, ...
        epochs.srate, epochs.length), 'b-', 'LineWidth', 2);

if ~baseonly
    % signal with maximum possible deviation (negative)
    plot(x, erp_generate_signal( ...
            class.peakLatency - class.peakLatencyDv, ...
            class.peakWidth - class.peakWidthDv, ...
            class.peakAmplitude - class.peakAmplitudeDv, ...
            epochs.srate, epochs.length), 'b:');

    % signal with maximum possible deviation (positive)
    plot(x, erp_generate_signal( ...
            class.peakLatency + class.peakLatencyDv, ...
            class.peakWidth + class.peakWidthDv, ...
            class.peakAmplitude + class.peakAmplitudeDv, ...
            epochs.srate, epochs.length), 'b--');

    if any([class.peakLatencySlope, class.peakWidthSlope, class.peakAmplitudeSlope])
       % additionally plotting the signal with maximum slope applied
            % mean
            plot(x, erp_generate_signal(...
                    class.peakLatency + class.peakLatencySlope, ...
                    class.peakWidth + class.peakWidthSlope, ...
                    class.peakAmplitude + class.peakAmplitudeSlope, ...
                    epochs.srate, epochs.length), 'r-', 'LineWidth', 2);

            % negative deviation
            plot(x, erp_generate_signal( ...
                    class.peakLatency + class.peakLatencySlope - class.peakLatencyDv, ...
                    class.peakWidth + class.peakWidthSlope - class.peakWidthDv, ...
                    class.peakAmplitude + class.peakAmplitudeSlope - class.peakAmplitudeDv, ...
                    epochs.srate, epochs.length), 'r:');

            % positive deviation
            plot(x, erp_generate_signal( ...
                    class.peakLatency + class.peakLatencySlope + class.peakLatencyDv, ...
                    class.peakWidth + class.peakWidthSlope + class.peakWidthDv, ...
                    class.peakAmplitude + class.peakAmplitudeSlope + class.peakAmplitudeDv, ...
                    epochs.srate, epochs.length), 'r--');
    end
end

end
