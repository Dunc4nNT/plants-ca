classdef material_type
    properties(Constant = true)
        VOID = 0
        IMMOVABLE = 1
        SUN = 2
        EARTH = 3
        AIR = 4
        SEED_BELOW = 5
        ROOT = 6
        LEAF = 7
        FLOWER = 8
        SEED_ABOVE = 9
    endproperties

    methods(Static = true)
        function colourmap = get_colourmap()
            colourmap = [
                0.1450980392156863, 0.09411764705882353, 0.1411764705882353; % VOID
                0, 0, 0; % IMMOVABLE
                0.9803921568627451, 0.8980392156862745, 0; % SUN
                0.3607843137254902, 0.25098039215686274, 0.15; % EARTH
                0.2196078431372549, 0.6980392156862745, 0.9215686274509803; % AIR
                0.7686274509803922, 0.7098039215686275, 0.5607843137254902; % SEED_BELOW
                0.8509803921568627, 0.7254901960784313, 0.6078431372549019; % ROOT
                0, 0.39215686274509803, 0; % LEAF
                1, 0.47843137254901963, 0.9568627450980393; % FLOWER
                0.7686274509803922, 0.7098039215686275, 0.5607843137254902; % SEED_ABOVE
            ];
        endfunction
    endmethods
endclassdef
