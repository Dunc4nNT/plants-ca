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
                0.1450980392156863, 0.09411764705882353, 0.1411764705882353;
                0, 0, 0;
                0.9803921568627451, 0.8980392156862745, 0;
                0.3686274509803922, 0.16470588235294117, 0;
                0.2196078431372549, 0.6980392156862745, 0.9215686274509803;
                0.7686274509803922, 0.7098039215686275, 0.5607843137254902;
                1, 0.34901960784313724, 0;
                0, 0.6196078431372549, 0.17647058823529413;
                1, 0.47843137254901963, 0.9568627450980393;
                0.7686274509803922, 0.7098039215686275, 0.5607843137254902;
            ];
        endfunction

        function energy = get_default_energy(type)
            switch (type)
                case material_type.IMMOVABLE
                    energy = Inf;
                case material_type.SUN
                    energy = Inf;
                case material_type.EARTH
                    energy = 0;
                case material_type.AIR
                    energy = 0;
                case material_type.SEED_BELOW
                    energy = 0;
                case material_type.SEED_ABOVE
                    energy = 0;
                case material_type.ROOT
                    energy = 0;
                case material_type.LEAF
                    energy = 0;
                case material_type.FLOWER
                    energy = 0;
                otherwise
            endswitch
        endfunction
    endmethods
endclassdef
