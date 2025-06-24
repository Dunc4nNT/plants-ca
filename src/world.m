classdef world
    properties
        width;
        height;
        generation;
        cells;
        start_generation_at;
        colourmap;
    endproperties

    methods(Access = "protected")
        function is_valid = _is_valid_size(self, x, name)
            is_valid = false;

            if (!isinteger(x))
                error([name, " must be an integer."])
            endif

            if (x < 10)
                error([name, " must be greater than or equal to 10."])
            endif

            if (mod(x, 2) != 0)
                error([name, " must be a multiple of two."])
            endif

            is_valid = true;
        endfunction
    endmethods

    methods
        function this = world(width, height, start_generation_at = uint32(0))
            if (this._is_valid_size(width, "Width"))
                this.width = width;
            endif

            if (this._is_valid_size(height, "Height"))
                this.height = height;
            endif

            this.start_generation_at = start_generation_at;
            this.cells = this.get_preset_cells();
            this.generation = this.start_generation_at;
            this.colourmap = [
                0.1450980392156863, 0.09411764705882353, 0.1411764705882353;
                0.8627450980392157, 0.8901960784313725, 0.8941176470588236;
            ];
        endfunction

        function reset_world(this)
            this.cells = this.get_preset_cells();
            this = this.reset_generation();
        endfunction

        function set_cells(this, new_cells)
            if (ndims(new_cells) != 2)
                error("New world cells must have exactly two dimensions.");
                return;
            endif

            this.width = rows(new_cells);
            this.height = columns(new_cells);
            this.cells = new_cells;
            this = this.reset_generation();
        endfunction

        function set_cell(this, x, y, new_cell)
            if (x < 1 | x > columns(this.cells) | y < 1 | y > rows(this.cells))
                error("Cell index is out of range.");
            endif

            this.cells(y, x) = new_cell;
        endfunction

        function cells = get_cells(this)
            cells = this.cells;
        endfunction

        function world_cell = get_cell(this, x, y)
            world_cell = this.cells(y, x);
        endfunction

        function this = reset_generation(this)
            this.generation = this.start_generation_at;
        endfunction

        function generation_str = generation_str(this)
            generation_str = ["Generation ", int2str(this.generation)];
        endfunction

        function generation = get_generation(this)
            generation = this.generation;
        endfunction

        function colourmap = get_colourmap(this)
            colourmap = this.colourmap;
        endfunction
    endmethods

    methods(Abstract)
        function cells = get_preset_cells(this)
        endfunction

        function this = next_step(this)
        endfunction

        function this = previous_step(this)
        endfunction

        function colours = get_colours(this)
        endfunction
    endmethods
endclassdef
