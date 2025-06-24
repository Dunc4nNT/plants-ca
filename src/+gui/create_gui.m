function data = create_gui(data)
    screensize = get(0.0, "screensize")(3:4);
    [data.SCREEN_WIDTH, data.SCREEN_HEIGHT] = num2cell(screensize){:};
    clear screensize;

    data.is_playing = false;
    data.default_play_speed = 0.905;
    data.play_speed = data.default_play_speed;
    data.is_editing = false;
    data.colourmap = [data.secondary_colour_800; data.primary_colour_200];

    data.fig = figure(
        "name", "Plants CA",
        "numbertitle", "off",
        "units", "normalized",
        "menubar", "none",
        "color", data.secondary_colour_600,
        "position", [0.125, 0.125, 0.75, 0.75],
        "sizechangedfcn", @on_window_size_change
    );

    data.axs = axes(
        "units", "normalized",
        "position", [0, 0, 0.75, 1],
        "colormap", data.colourmap
    );

    data.img = imagesc(data.axs, data.world.get_colours());
    axis(data.axs, "off");

    data.previous_step_button = uicontrol(
        "style", "pushbutton",
        "units", "normalized",
        "string", "Previous Step",
        "foregroundcolor", data.colour_grey_800,
        "backgroundcolor", data.secondary_colour_300,
        "position", [0.80, 0.80, 0.15, 0.05],
        "fontunits", "normalized",
        "fontsize", data.font_size_300,
        "tooltipstring", "Step to the previous generation.",
        "callback", @on_previous_step
    );

    data.next_step_button = uicontrol(
        "style", "pushbutton",
        "units", "normalized",
        "string", "Next Step",
        "foregroundcolor", data.colour_grey_800,
        "backgroundcolor", data.secondary_colour_300,
        "position", [0.80, 0.90, 0.15, 0.05],
        "fontunits", "normalized",
        "fontsize", data.font_size_300,
        "tooltipstring", "Step to the next generation.",
        "callback", @on_next_step
    );

    data.reset_button = uicontrol(
        "style", "pushbutton",
        "units", "normalized",
        "string", "Reset World",
        "foregroundcolor", data.colour_grey_800,
        "backgroundcolor", data.secondary_colour_300,
        "position", [0.80, 0.70, 0.15, 0.05],
        "fontunits", "normalized",
        "fontsize", data.font_size_300,
        "tooltipstring", "Reset world with random cells.",
        "callback", @on_reset
    );

    data.generation_label = uicontrol(
        "style", "text",
        "units", "normalized",
        "string", data.world.generation_str(),
        "foregroundcolor", data.colour_grey_800,
        "backgroundcolor", data.secondary_colour_300,
        "position", [0.80, 0.60, 0.15, 0.05],
        "fontunits", "normalized",
        "fontsize", data.font_size_300
    );

    data.export_button = uicontrol(
        "style", "pushbutton",
        "units", "normalized",
        "string", "Export World",
        "foregroundcolor", data.colour_grey_800,
        "backgroundcolor", data.secondary_colour_300,
        "position", [0.80, 0.50, 0.15, 0.05],
        "fontunits", "normalized",
        "fontsize", data.font_size_300,
        "tooltipstring", "Export the world.",
        "callback", @on_export
    );

    data.import_button = uicontrol(
        "style", "pushbutton",
        "units", "normalized",
        "string", "Import World",
        "foregroundcolor", data.colour_grey_800,
        "backgroundcolor", data.secondary_colour_300,
        "position", [0.80, 0.40, 0.15, 0.05],
        "fontunits", "normalized",
        "fontsize", data.font_size_300,
        "tooltipstring", "Import a world.",
        "callback", @on_import
    );

    data.toggle_play_button = uicontrol(
        "style", "togglebutton",
        "units", "normalized",
        "string", "Toggle Play",
        "foregroundcolor", data.colour_grey_800,
        "backgroundcolor", data.secondary_colour_300,
        "position", [0.80, 0.30, 0.15, 0.05],
        "fontunits", "normalized",
        "fontsize", data.font_size_300,
        "tooltipstring", "Play or pause the automaton simulation.",
        "callback", @on_toggle_play
    );

    data.adjust_speed_button = uicontrol(
        "style", "slider",
        "units", "normalized",
        "string", "Speed",
        "min", 0.005,
        "max", 1.0,
        "value", data.default_play_speed,
        "sliderstep", [0.001, 0.005],
        "foregroundcolor", data.colour_grey_800,
        "backgroundcolor", data.secondary_colour_300,
        "position", [0.80, 0.20, 0.15, 0.05],
        "fontunits", "normalized",
        "fontsize", data.font_size_300,
        "tooltipstring", "Adjust the simulation speed.",
        "callback", @on_adjust_speed
    );

    data.toggle_edit_mode_button = uicontrol(
        "style", "togglebutton",
        "units", "normalized",
        "string", "Toggle Edit Mode",
        "foregroundcolor", data.colour_grey_800,
        "backgroundcolor", data.secondary_colour_300,
        "position", [0.80, 0.10, 0.15, 0.05],
        "fontunits", "normalized",
        "fontsize", data.font_size_300,
        "tooltipstring", "Toggle edit world mode.",
        "callback", @on_toggle_edit_mode
    );
    
    guidata(data.fig, data);
    drawnow();

    waitfor(data.fig);
endfunction


% Update world and UI elements.
function update_gui(data, source)
    set(data.img, "cdata", data.world.cells);
    set(data.generation_label, "string", data.world.generation_str());
    guidata(source, data);
    drawnow();
endfunction

function on_previous_step(source, event)
    data = guidata(source);

    data.world = data.world.previous_step();

    update_gui(data, source);
endfunction

function on_next_step(source, event)
    data = guidata(source);

    data.world = data.world.next_step();

    update_gui(data, source);
endfunction

function on_reset(source, event)
    data = guidata(source);

    data.world = data.world.reset_world();

    update_gui(data, source);
endfunction

function on_export(source, event)
    data = guidata(source);
    valid_export_formats = {"*.txt;*.csv", "Text Files"; "*.png;", "Images"};

    [filename, filepath] = uiputfile(
        valid_export_formats,
        "Choose a file name to save",
        "world.txt"
    );

    if (endsWith(filename, {".png"}))
        imwrite(data.world.cells, [filepath, filename]);
    elseif (endsWith(filename, {".txt", ".csv"}))
        csvwrite([filepath, filename], data.world.cells);
    else
        errordlg("File save format not supported.", "SAVE ERROR");
        return;
    endif
endfunction

function on_import(source, event)
    data = guidata(source);
    valid_import_formats = {"*.txt;*.csv", "Text Files"; "*.png;", "Images"};

    [filename, filepath] = uigetfile(
        valid_import_formats,
        "Select a file to load.",
        "world.txt"
    );

    if (endsWith(filename, {".png"}))
        imported_world = imread([filepath, filename]);
    elseif (endsWith(filename, {".txt", ".csv"}))
        imported_world = csvread([filepath, filename]);
    else
        errordlg("File save format not supported.", "Error Saving");
        return;
    endif

    try
        data.world = data.world.set_cells(logical(imported_world));
    catch err
        errordlf(err.message, "IMPORT ERROR");
        return;
    end_try_catch

    update_gui(data, source);
endfunction

function on_toggle_play(source, event)
    data = guidata(source);

    data.is_playing = get(gcbo, "value");
    guidata(source, data);

    while data.is_playing
        data.world = data.world.next_step();

        update_gui(data, source);
        pause(1.005 - data.play_speed);

        % BUG: when exiting the application while playing is on, this errors as source is no longer valid.
        data = guidata(source);
    endwhile
endfunction

function on_adjust_speed(source, event)
    data = guidata(source);

    data.play_speed = get(gcbo, "value");
    guidata(source, data);
endfunction

function on_toggle_edit_mode(source, event)
    data = guidata(source);

    data.is_editing = get(gcbo, "value");
    guidata(source, data);

    while (data.is_editing)
        [x, y, button] = ginput(1);
        data = guidata(source);
        if (!data.is_editing)
            break;
        endif

        if (button == 1)
            x = round(x);
            y = round(y);

            cells = data.world.get_cells();
            if (!(x < 1 | x > columns(cells) | y < 1 | y > rows(cells)))
                data.world = data.world.flip_cell(x, y);
                update_gui(data, source);
            endif
        endif

        pause(0.1);
        data = guidata(source);
    endwhile
endfunction

function on_window_size_change(source, event)
    data = guidata(source);
    update_gui(data, source);
endfunction
