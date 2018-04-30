% EEG = pop_sereega_sources(EEG)
%
%       Pops up a dialog window that allows you to add and remove sources
%       from the simulation.
%
%       The pop_ functions serve only to provide a GUI for some of
%       SEREEGA's functions and are not intended to be used in scripts.
%
%       To add sources to the simulation, first use one of the four options
%       provided to find sources in the lead field:
%       - Next to "random", indicate the number of randomly selected
%         sources you wish to inspect;
%       - Next to "nearest to", indicate the coordinates in the brain where
%         you wish to find a source;
%       - Next to "spaced", indicate the number of sources you wish to
%         find, and the minimum distance in mm between them;
%       - Next to "in radius", indicate the location in the brain (or the
%         ID of the source) and the size of the radius in mm.
%       Click "find" to find the source(s). They will show up below under
%       "found location", along with their default orientation. Click
%       "plot" to inspect these values graphically.
%
%       The default orientation can be changed. Next to "orientation", a
%       custom orientation can be indicated and applied by clicking
%       "apply". Alternatively, the default orientation can be restored by
%       clicking "default", a random orientation can be given by clicking
%       "random", or a pseudoperpendicular/pseudotangential orientation by
%       clicking the corresponding buttons.
%
%       When satisfied with the found source location and orientation, it
%       can be added to the simulation by clicking "add source(s)". 
%
%       At the left side of the window, a list indicates the sources
%       currently added to the simulation. Clicking on them sets their
%       values as before, and allows them to be plotted. Click "remove
%       source" to remove a source from the simulation.
%
%       See for details: lf_get_source_random, lf_get_source_nearest,
%       lf_get_source_spaced, lf_get_source_inradius,
%       utl_get_orientation_random,
%       utl_get_orientation_pseudoperpendicular,
%       utl_get_orientation_pseudotangential
%
% In:
%       EEG - an EEGLAB dataset that includes a SEREEGA lead field in
%             EEG.etc.sereega.leadfield
%
% Out:  
%       EEG - the EEGLAB dataset with sources according to the actions
%             taken in the dialog
% 
%                    Copyright 2018 Laurens R Krol
%                    Team PhyPA, Biological Psychology and Neuroergonomics,
%                    Berlin Institute of Technology

% 2018-04-25 First version

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

function EEG = pop_sereega_sources(EEG)

% testing if lead field is present
if ~isfield(EEG.etc, 'sereega') || ~isfield(EEG.etc.sereega, 'leadfield') ...
        || isempty(EEG.etc.sereega.leadfield)
    errormsg = 'First add a lead field to the simulation.';
    supergui( 'geomhoriz', { 1 1 1 }, 'uilist', { ...
            { 'style', 'text', 'string', errormsg }, { }, ...
            { 'style', 'pushbutton' , 'string', 'OK', 'callback', 'close(gcbf);'} }, ...
            'title', 'Error');
    return
end

% adding empty 'sources' field if no sources were added befor
if ~isfield(EEG.etc.sereega, 'sources')
    EEG.etc.sereega.sources.sourceidx = [];
    EEG.etc.sereega.sources.orientation = [];
end

% setting userdata
userdata.newsourceidx = [];
userdata.newsourceorientation = [];
userdata.plotlocationhandle = [];
userdata.plotprojectionhandle = [];
userdata.currentsourceidx = EEG.etc.sereega.sources.sourceidx;
userdata.currentsourceorientation = EEG.etc.sereega.sources.orientation;

% generating list of current sources
currentsourcelist = {}; ...
for i = 1:numel(userdata.currentsourceidx), ...
    currentsourcelist = [currentsourcelist, {sprintf('%d at ( %d, %d, %d )', i, round(EEG.etc.sereega.leadfield.pos(EEG.etc.sereega.sources.sourceidx(i),:)))}]; ...
end

% general callback functions
cbf_get_userdata = 'userdatafig = gcf; userdata = get(userdatafig, ''userdata'');';
cbf_set_userdata = 'set(userdatafig, ''userdata'', userdata);';
cbf_get_value = @(tag,property) sprintf('get(findobj(''parent'', gcbf, ''tag'', ''%s''), ''%s'')', tag, property);
cbf_set_value = @(tag,property,value) sprintf('set(findobj(''parent'', gcbf, ''tag'', ''%s''), ''%s'', %s);', tag, property, value);
cbf_update_fields = [ ...
        cbf_get_userdata ...
        'if isempty(userdata.newsourceidx),' ...
            cbf_set_value('found_location', 'string', '''no source found''') ...
            cbf_set_value('found_orientation', 'string', '''no source found''') ...
        'elseif numel(userdata.newsourceidx) == 1,' ...
            'sourcepos = sprintf(''( %d, %d, %d )'', round(EEG.etc.sereega.leadfield.pos(userdata.newsourceidx,:)));' ...
            'sourceori = sprintf(''( %.2f, %.2f, %.2f )'', userdata.newsourceorientation);' ...
            cbf_set_value('found_location', 'string', 'sourcepos') ...
            cbf_set_value('found_orientation', 'string', 'sourceori') ...
        'elseif numel(userdata.newsourceidx) > 1,' ...
            cbf_set_value('found_location', 'string', 'sprintf(''(%d locations)'', numel(userdata.newsourceidx))') ...
            cbf_set_value('found_orientation', 'string', 'sprintf(''(%d orientations)'', numel(userdata.newsourceidx))') ...
        'end;' ...
        'currentsourcelist = {};' ...
        'for i = 1:numel(userdata.currentsourceidx),' ...
            'currentsourcelist = [currentsourcelist, {sprintf(''%d at ( %d, %d, %d )'', i, round(EEG.etc.sereega.leadfield.pos(userdata.currentsourceidx(i),:)))}];' ...
        'end;' ...
        cbf_set_value('currentsources', 'string', 'currentsourcelist'); ...
        ];
cbf_update_plot_location = [ ...
        cbf_get_userdata ...
        'if ~isempty(userdata.plotlocationhandle) && all(ishandle(userdata.plotlocationhandle)),' ...
            'sourcecolour = [ones(numel(userdata.newsourceidx),1), transpose(linspace(.6, .3, numel(userdata.newsourceidx))), transpose(linspace(.6, .3, numel(userdata.newsourceidx)))];' ...
            'sourcecolour = sourcecolour(randperm(numel(userdata.newsourceidx)), :);' ...
            'set(userdata.plotlocationhandle(2), ''XData'', EEG.etc.sereega.leadfield.pos(userdata.newsourceidx,1), ''YData'', EEG.etc.sereega.leadfield.pos(userdata.newsourceidx,3), ''CData'', sourcecolour);' ...
            'set(userdata.plotlocationhandle(3), ''XData'', EEG.etc.sereega.leadfield.pos(userdata.newsourceidx,2), ''YData'', EEG.etc.sereega.leadfield.pos(userdata.newsourceidx,3), ''CData'', sourcecolour);' ...
            'set(userdata.plotlocationhandle(4), ''XData'', EEG.etc.sereega.leadfield.pos(userdata.newsourceidx,1), ''YData'', EEG.etc.sereega.leadfield.pos(userdata.newsourceidx,2), ''CData'', sourcecolour);' ...
        'end;' ...
        ];
cbf_update_plot_projection = [ ...
        cbf_get_userdata ...
        'if ~isempty(userdata.plotprojectionhandle) && ishandle(userdata.plotprojectionhandle),' ...
            'evalc(''plot_source_projection(userdata.newsourceidx, EEG.etc.sereega.leadfield, ''''orientation'''', userdata.newsourceorientation, ''''handle'''', userdata.plotprojectionhandle);'');' ...
        'end;' ...
        ];

% callbacks
cb_find_source_random = [ ...
        cbf_get_userdata ...
        'numsources = str2num(' cbf_get_value('fnd_src_random', 'string') '); ' ...
        'if ~isempty(numsources),'...
            'userdata.newsourceidx = lf_get_source_random(EEG.etc.sereega.leadfield, numsources);' ...
            'userdata.newsourceorientation = EEG.etc.sereega.leadfield.orientation(userdata.newsourceidx,:);' ...
        'end;' ...
        cbf_set_userdata ...
        cbf_update_fields ...
        cbf_update_plot_location ...
        cbf_update_plot_projection ...
        ];
cb_find_source_nearest = [ ...
        cbf_get_userdata ...
        'xyz = str2num(' cbf_get_value('fnd_src_nearest', 'string') '); ' ...
        'if ~isempty(xyz),'...
            'userdata.newsourceidx = lf_get_source_nearest(EEG.etc.sereega.leadfield, xyz);' ...
            'userdata.newsourceorientation = EEG.etc.sereega.leadfield.orientation(userdata.newsourceidx,:);' ...
        'end;'...
        cbf_set_userdata ...
        cbf_update_fields ...
        cbf_update_plot_location ...
        cbf_update_plot_projection ...
        ];
cb_find_source_spaced = [ ...
        cbf_get_userdata ...
        'num = str2num(' cbf_get_value('fnd_src_spaced_num', 'string') '); ' ...
        'mm = str2num(' cbf_get_value('fnd_src_spaced_mm', 'string') '); ' ...
        'if ~isempty(num) && ~isempty(mm),' ...
            'userdata.newsourceidx = lf_get_source_spaced(EEG.etc.sereega.leadfield, num, mm);' ...
            'userdata.newsourceorientation = EEG.etc.sereega.leadfield.orientation(userdata.newsourceidx,:);' ...
        'end;' ...
        cbf_set_userdata ...
        cbf_update_fields ...
        cbf_update_plot_location ...
        cbf_update_plot_projection ...
        ];
cb_find_source_inradius = [ ...
        cbf_get_userdata ...
        'pos = str2num(' cbf_get_value('fnd_src_radius_pos', 'string') '); ' ...
        'mm = str2num(' cbf_get_value('fnd_src_radius_mm', 'string') '); ' ...
        'if ~isempty(pos) && ~isempty(mm),'...
            'userdata.newsourceidx = lf_get_source_inradius(EEG.etc.sereega.leadfield, pos, mm);' ...
            'userdata.newsourceorientation = EEG.etc.sereega.leadfield.orientation(userdata.newsourceidx,:);' ...
        'end;' ...
        cbf_set_userdata ...
        cbf_update_fields ...
        'if numel(userdata.newsourceidx) > 1,' ...
            cbf_update_plot_location ...
            cbf_update_plot_projection ...
        'end;'
        ];
    
cb_apply_orientation = [ ...
        cbf_get_userdata ...
        'orientation = str2num(' cbf_get_value('orientation', 'string') '); ' ...
        'if ~isempty(orientation),'...
            'userdata.newsourceorientation = orientation;' ...
        'end;' ...
        cbf_set_userdata ...
        cbf_update_fields ...
        ];
cb_orient_default = [ ...
        cbf_get_userdata ...
        'if ~isempty(userdata.newsourceidx),'...
            'userdata.newsourceorientation = EEG.etc.sereega.leadfield.orientation(userdata.newsourceidx,:);' ...
        'end;' ...
        cbf_set_userdata ...
        cbf_update_fields ...
        cbf_update_plot_projection ...
        ];
cb_orient_random = [ ...
        cbf_get_userdata ...
        'if ~isempty(userdata.newsourceidx),'...
            'userdata.newsourceorientation = utl_get_orientation_random(numel(userdata.newsourceidx));' ...
        'end;' ...
        cbf_set_userdata ...
        cbf_update_fields ...
        cbf_update_plot_projection ...
        ];
cb_orient_perpend = [ ...
        cbf_get_userdata ...
        'if ~isempty(userdata.newsourceidx),'...
            'userdata.newsourceorientation = utl_get_orientation_pseudoperpendicular(userdata.newsourceidx, EEG.etc.sereega.leadfield);' ...
        'end;' ...
        cbf_set_userdata ...
        cbf_update_fields ...
        cbf_update_plot_projection ...
        ];
cb_orient_tangent = [ ...
        cbf_get_userdata ...
        'if ~isempty(userdata.newsourceidx),'...
            'userdata.newsourceorientation = utl_get_orientation_pseudotangential(userdata.newsourceidx, EEG.etc.sereega.leadfield);' ...
        'end;' ...
        cbf_set_userdata ...
        cbf_update_fields ...
        cbf_update_plot_projection ...
        ];
    
cb_plot_location = [ ...
        cbf_get_userdata ...
        'if isempty(userdata.plotlocationhandle) || ~all(ishandle(userdata.plotlocationhandle)),' ...
            '[h, hsxz, hsyz, hsxy] = plot_source_location(userdata.newsourceidx, EEG.etc.sereega.leadfield);' ...
            'userdata.plotlocationhandle = [h, hsxz, hsyz, hsxy];' ...
            cbf_set_userdata ...
        'else,' ...
            cbf_update_plot_location ...
        'end;' ...
        ];
cb_plot_projection = [ ...
        cbf_get_userdata ...
        'if isempty(userdata.plotprojectionhandle) || ~ishandle(userdata.plotprojectionhandle),' ...
            'h = plot_source_projection(userdata.newsourceidx, EEG.etc.sereega.leadfield, ''orientation'', userdata.newsourceorientation);' ...
            'userdata.plotprojectionhandle = h;' ...
            cbf_set_userdata ...
        'else,' ...
            cbf_update_plot_projection ...
        'end;' ...
        ];
    
cb_add_source = [ ...
        cbf_get_userdata ...
        'userdata.currentsourceidx = [userdata.currentsourceidx, userdata.newsourceidx];' ...
        'userdata.currentsourceorientation = [userdata.currentsourceorientation; userdata.newsourceorientation];' ...
        cbf_set_userdata ...
        cbf_update_fields ...
        ];
cb_select_source = [ ...
        cbf_get_userdata ...
        'src = ' cbf_get_value('currentsources', 'value') ';' ...
        'userdata.newsourceidx = userdata.currentsourceidx(src);' ...
        'userdata.newsourceorientation = userdata.currentsourceorientation(src,:);' ...
        cbf_set_userdata ...
        cbf_update_fields ...
        cbf_update_plot_location ...
        cbf_update_plot_projection ...
        ];
cb_remove_source = [ ...
        cbf_get_userdata ...
        'src = ' cbf_get_value('currentsources', 'value') ';' ...
        'userdata.currentsourceidx(src) = [];' ...
        'userdata.currentsourceorientation(src,:) = [];' ...
        cbf_set_userdata ...
        cbf_update_fields ...
        cb_select_source ...
        ];

% geometry
nc = 6; nr = 14;
geom = { ...
        { nc nr [ 0  0]    ...  % current sources text
                [ 2  1] }, ...
                { nc nr [ 0  1]    ...  % listbox
                        [ 2 11] }, ...
                { nc nr [ 0 13]    ...  % remove source
                        [ 2  1] }, ...
        { nc nr [ 2  0]    ...  % add sources text
                [ 6  1] }, ...
                { nc nr [ 2  1]    ...  % add sources: random text
                        [ 1  1] }, ...
                        { nc nr [ 3  1]    ...  % edit
                                [ 2  1] }, ...
                        { nc nr [ 5  1]    ...  % find
                                [ 1  1] }, ...
                { nc nr [ 2  2]    ...  % add sources: nearest text
                        [ 1  1] }, ...
                        { nc nr [ 3  2]    ...  % edit
                                [ 2  1] }, ...
                        { nc nr [ 5  2]    ...  % find
                                [ 1  1] }, ...
                { nc nr [ 2  3]    ...  % add sources: spaced text
                        [ 1  1] }, ...
                        { nc nr [ 3  3]    ...  % edit #
                                [ 1  1] }, ...
                        { nc nr [ 4  3]    ...  % edit mm
                                [ 1  1] }, ...
                        { nc nr [ 5  3]    ...  % find
                                [ 1  1] }, ...
                { nc nr [ 2  4]    ...  % add sources: radius text
                        [ 1  1] }, ...
                        { nc nr [ 3  4]    ...  % edit xyz
                                [ 1  1] }, ...
                        { nc nr [ 4  4]    ...  % edit mm
                                [ 1  1] }, ...
                        { nc nr [ 5  4]    ...  % find
                                [ 1  1] }, ...
                { nc nr [ 2  6]    ...  % orientation text
                        [ 1  1] }, ...
                        { nc nr [ 3  6]    ...  % orientation edit
                                [ 2  1] }, ...
                        { nc nr [ 3  7]    ...  % orientation default
                                [ 1  1] }, ...
                        { nc nr [ 4  7]    ...  % orientation random
                                [ 1  1] }, ...
                        { nc nr [ 3  8]    ...  % orientation perpendicular
                                [ 1  1] }, ...
                        { nc nr [ 4  8]    ...  % orientation tangential
                                [ 1  1] }, ...
                        { nc nr [ 5  6]    ...  % orientation apply
                                [ 1  1] }, ...
                { nc nr [ 2 10]    ...  % found location text
                        [ 1  1] }, ...
                        { nc nr [ 3 10]    ...  % xyz
                                [ 2  1] }, ...
                        { nc nr [ 5 10]    ...  % plot
                                [ 1  1] }, ...
                { nc nr [ 2 11]    ...  % found orientation text
                        [ 1  1] }, ...
                        { nc nr [ 3 11]    ...  % xyz
                                [ 2  1] }, ...
                        { nc nr [ 5 11]    ...  % plot
                                [ 1  1] }, ...
                { nc nr [ 3 13]    ...  % add sources
                        [ 2  1] }, ...
       };

% building gui
[~, userdata, ~, ~] = inputgui('geom', geom, ...
        'uilist', { ...
                { 'style' 'text' 'string' 'Current sources', 'fontweight', 'bold' } ...
                        { 'style' 'listbox' 'string' currentsourcelist, 'tag', 'currentsources', 'callback', cb_select_source } ...
                        { 'style' 'pushbutton' 'string' 'Remove source', 'callback', cb_remove_source } ...
                { 'style' 'text' 'string' 'Add new sources', 'fontweight', 'bold' } ...
                        { 'style' 'text' 'string' 'Random' } ...
                                { 'style' 'edit' 'string' '#', 'tag', 'fnd_src_random' } ...
                                { 'style' 'pushbutton' 'string' 'Find', 'callback', cb_find_source_random } ...
                        { 'style' 'text' 'string' 'Nearest to' } ...
                                { 'style' 'edit' 'string' 'x y z', 'tag', 'fnd_src_nearest' } ...
                                { 'style' 'pushbutton' 'string' 'Find', 'callback', cb_find_source_nearest } ...
                        { 'style' 'text' 'string' 'Spaced' } ...
                                { 'style' 'edit' 'string' '#', 'tag', 'fnd_src_spaced_num' } ...
                                { 'style' 'edit' 'string' 'mm', 'tag', 'fnd_src_spaced_mm' } ...
                                { 'style' 'pushbutton' 'string' 'Find', 'callback', cb_find_source_spaced } ...
                        { 'style' 'text' 'string' 'In radius' } ...
                                { 'style' 'edit' 'string' 'x y z', 'tag', 'fnd_src_radius_pos' } ...
                                { 'style' 'edit' 'string' 'mm', 'tag', 'fnd_src_radius_mm' } ...
                                { 'style' 'pushbutton' 'string' 'Find', 'callback', cb_find_source_inradius } ...
                        { 'style' 'text' 'string' 'Orientation' } ...
                                { 'style' 'edit' 'string' 'x y z', 'tag', 'orientation' } ...
                                { 'style' 'pushbutton' 'string' 'Default', 'callback', cb_orient_default } ...
                                { 'style' 'pushbutton' 'string' 'Random', 'callback', cb_orient_random } ...
                                { 'style' 'pushbutton' 'string' [char(177) ' Perpend.'], 'callback', cb_orient_perpend } ...
                                { 'style' 'pushbutton' 'string' [char(177) ' Tangent.'], 'callback', cb_orient_tangent } ...
                                { 'style' 'pushbutton' 'string' 'Apply', 'callback', cb_apply_orientation } ...
                        { 'style' 'text' 'string' 'Found location' } ...
                                { 'style' 'edit' 'string' '( x, y, z )', 'tag', 'found_location', 'enable', 'off' } ...
                                { 'style' 'pushbutton' 'string' 'Plot', 'callback', cb_plot_location } ...
                        { 'style' 'text' 'string' 'Orientation' } ...
                                { 'style' 'edit' 'string' '( x, y, z )', 'tag', 'found_orientation', 'enable', 'off' } ...
                                { 'style' 'pushbutton' 'string' 'Plot', 'callback', cb_plot_projection } ...
                        { 'style' 'pushbutton' 'string' 'Add source(s)', 'callback', cb_add_source } ...
                }, ...
                'helpcom', 'pophelp(''pop_sereega_sources'');', ...
                'title', 'Add sources to the simulation', ...
                'userdata', userdata);
     
% saving sources
if ~isempty(userdata)
    EEG.etc.sereega.sources.sourceidx = userdata.currentsourceidx;
    EEG.etc.sereega.sources.orientation = userdata.currentsourceorientation;
end

end
