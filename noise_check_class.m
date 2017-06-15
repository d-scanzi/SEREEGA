% class = noise_check_class(class)
%
%       Validates and completes a noise class structure.
%
%       Noise is defined by its type and its amplitude.
%       Additionally, the epoch-to-epoch variability of the amplitude is
%       indicated using a possible deviation (Dv), and the change over time
%       is indicated using a slope. Finally, a probability can be set for
%       the appearance of the signal as a whole.
%
%       The amplitude represents the maximum absolute amplitude of any
%       point in the noise signal.
%
%       The Deviation represents the epoch-to-epoch (trial-to-trial) 
%       variability. A deviation of .05 for an amplitude of .1 means that
%       the amplitude varies according to a normal distribution, with 99.7% 
%       of amplitudes being between .05 and .15. A deviation of 0
%       means all signals will be exactly the same (barring any sloping).
%
%       The probability can range from 0 (this signal will never be 
%       generated) to 1 (this signal will be generated for every single
%       epoch). 
%
%       A complete noise class definition includes the following fields:
%
%         .type:                 class type (must be 'noise')
%         .color:                noise color, 'white'|'pink'|'brown'
%         .peakAmplitude:        1-by-n matrix of peak amplitudes
%         .peakAmplitudeDv:      1-by-n matrix of peak amplitude deviations
%         .peakAmplitudeSlope:   1-by-n matrix of peak amplitude slopes
%         .probability:          0-1 scalar indicating probability of
%                                appearance
%         .probabilitySlope:     scalar, slope of the probability
%
% In:
%       class - the class variable as a struct with at least the required
%               fields: peakLatency, peakWidth, and peakAmplitude
%
% Out:  
%       class - the class variable struct with all fields completed
%
% Usage example:
%       >> noise.color = 'white'; noise.amplitude = .1;
%       >> noise = noise_check_class(noise)
% 
%                    Copyright 2017 Laurens R Krol
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology

% 2017-06-15 First version

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

function class = noise_check_class(class)

% checking for required variables
if ~isfield(class, 'color')
    error('field color is missing from given noise class variable');
elseif ~isfield(class, 'amplitude')
    error('field amplitude is missing from given noise class variable');
elseif isfield(class, 'type') && ~isempty(class.type) && ~strcmp(class.type, 'noise')
    error('indicated type (''%s'') not set to ''noise''', class.type);
end

% adding fields / filling in defaults
if ~isfield(class, 'type') || isempty(class.type),
    class.type = 'noise'; end

if ~isfield(class, 'amplitudeDv'),
    class.amplitudeDv = 0; end

if ~isfield(class, 'amplitudeSlope'),
    class.amplitudeSlope = 0; end

if ~isfield(class, 'probability'),
    class.probability = 1; end

if ~isfield(class, 'probabilitySlope'),
    class.probabilitySlope = 0; end

class = orderfields(class);

% checking values
if ~ismember(class.color, {'white', 'pink', 'brown'});
    error('an unknown noise color is indicated in the given noise class variable');
    
end
