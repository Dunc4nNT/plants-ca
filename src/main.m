clear all;
close all;

data.world_width = uint32(10);
data.world_height = uint32(10);
data.start_generation_at = uint32(0);
data.primary_colour_200 = [0.8627450980392157, 0.8901960784313725, 0.8941176470588236];
data.secondary_colour_300 = [0.8117647058823529, 0.7098039215686275, 0.803921568627451];
data.secondary_colour_600 = [0.43529411764705883, 0.28627450980392155, 0.42745098039215684];
data.secondary_colour_800 = [0.1450980392156863, 0.09411764705882353, 0.1411764705882353];
data.colour_white = [1, 1, 1];
data.colour_grey_200 = [0.8509803921568627, 0.8509803921568627, 0.8509803921568627];
data.colour_grey_800 = [0.25098039215686274, 0.25098039215686274, 0.25098039215686274];
data.colour_black = [0, 0, 0];
data.font_size_300 = 0.5;

function init(data)
    data.world = plants_world(data.world_width, data.world_height, data.start_generation_at);
    data = gui.create_gui(data);

    waitfor(data.fig);
endfunction

init(data)
