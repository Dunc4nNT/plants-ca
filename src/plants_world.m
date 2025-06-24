classdef plants_world < world
    methods
        function this = plants_world(width, height, start_generation_at = uint32(0))
            this@world(width, height, start_generation_at);
        endfunction

        function cells = get_preset_cells(this)
            cells = zeros(this.height, this.width);
        endfunction

        function this = next_step(this)
            error("next_step is not implemented.")
        endfunction

        function this = previous_step(this)
            error("previous_step is not implemented.")
        endfunction
    endmethods
endclassdef
