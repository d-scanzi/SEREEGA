% scalpdata = generate_scalpdata(component, leadfield, epochs, varargin)
%
%       Generates simulated scalp data by simulating all signals in all
%       components, projecting them through the leadfield using the given
%       source and orientation, and summing them together, for all of the
%       indicated epochs.
%
% In:
%       component - 1-by-n struct of components (see utl_check_component)
%       leadfield - a leadfield struct
%       epochs - single epoch configuration struct containing at least
%                sampling rate (srate), epoch length (length), and total
%                number of epochs (n)
%
% Optional (key-value pairs):
%       normaliseLeadfield - 1|0, whether or not to normalise the
%                            leadfields before  projecting the signal to
%                            have the most extreme value be either 1 or -1,
%                            depending on its sign. default: 1
%       normaliseOrientation - 1|0, as above, except for orientation
%       showprogress - 1|0, whether or not to show a progress bar
%                      (default 1)
%
% Out:
%       scalpdata - channels x samples x epochs array of simulated scalp
%                   data
%
% Usage example:
%       >> lf = lf_generate_fromnyhead;
%       >> epochs.n = 100; epochs.srate = 500; epochs.length = 1000;
%       >> s.peakLatency = 200; s.peakWidth = 100; s.peakAmplitude = 1;
%       >> s = utl_check_class(s, 'type', 'erp');
%       >> c.source = 1; c.signal = {s};
%       >> c = utl_check_component(c, lf);
%       >> scalpdata = generate_scalpdata(c, lf, epochs);
% 
%                    Copyright 2017 Laurens R Krol
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology

% 2017-06-14 First version

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

function scalpdata = generate_scalpdata(component, leadfield, epochs, varargin)

% parsing input
p = inputParser;

addRequired(p, 'component', @isstruct);
addRequired(p, 'leadfield', @isstruct);
addRequired(p, 'epochs', @isstruct);

addParamValue(p, 'normaliseLeadfield', 1, @isnumeric);
addParamValue(p, 'normaliseOrientation', 1, @isnumeric);
addParamValue(p, 'showprogress', 1, @isnumeric);

parse(p, component, leadfield, epochs, varargin{:})

component = p.Results.component;
leadfield = p.Results.leadfield;
epochs = p.Results.epochs;
normaliseLeadfield = p.Results.normaliseLeadfield;
normaliseOrientation = p.Results.normaliseOrientation;
showprogress = p.Results.showprogress;

scalpdata = zeros(numel(leadfield.chanlocs), floor((epochs.length/1000)*epochs.srate), epochs.n);

if showprogress, w = waitbar(0, sprintf('Epoch 0 of %d', epochs.n), 'Name', 'Generating scalp data'); end

% for each epoch...
for e = 1:epochs.n
    if showprogress, waitbar(e/epochs.n, w, sprintf('Epoch %d of %d', e, epochs.n), 'Name', 'Generating scalp data'); end
    componentdata = zeros(numel(leadfield.chanlocs), floor((epochs.length/1000)*epochs.srate), numel(component));
    
    % for each component...
    for c = 1:numel(component)
        % getting component's sum signal
        componentsignal = generate_signal_fromcomponent(component(c), epochs, 'epochNumber', e);

        % obtaining single source
        n = randperm(numel(component(c).source));
        n = n(1);
        source = component(c).source(n);

        % obtaining orientation
        orientation = component(c).orientation(n,:);
        orientationDv = component(c).orientationDv(n,:);
        orientation = utl_apply_dvslope(orientation, orientationDv, zeros(size(orientation)), e, epochs.n);

        % projecting signal
        componentdata(:,:,c) = lf_project_signal(componentsignal, leadfield, source, orientation, ...
                'normaliseLeadfield', normaliseLeadfield, ...
                'normaliseOrientation', normaliseOrientation);
    end
    
    % combining projected component signals into single epoch
    scalpdata(:,:,e) = sum(componentdata, 3);
end

if showprogress, delete(w); end

end