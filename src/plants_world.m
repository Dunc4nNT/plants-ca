classdef plants_world < world
    methods
        function this = plants_world(width, height, start_generation_at = uint32(0))
            this@world(width, height, start_generation_at);

            this.colourmap = material_type.get_colourmap();
        endfunction

        function world_material = create_material(this, type, energy = 0)
            world_material.type = type;
            world_material.energy = energy;
        endfunction

        function cells = get_preset_cells(this)
            sun_cell = this.create_material(
                material_type.SUN,
                material_type.get_default_energy(material_type.SUN)
            );
            sun_mat = repmat(sun_cell, 2, this.width);

            immovable_cell = this.create_material(
                material_type.IMMOVABLE,
                material_type.get_default_energy(material_type.IMMOVABLE)
            );
            immovable_mat = repmat(immovable_cell, 2, this.width);

            air_cell = this.create_material(
                material_type.AIR,
                material_type.get_default_energy(material_type.AIR)
            );
            air_mat = repmat(air_cell, this.height / 2 - 2, this.width);

            earth_cell = this.create_material(
                material_type.EARTH,
                material_type.get_default_energy(material_type.EARTH)
            );
            earth_mat = repmat(earth_cell, this.height / 2 - 2, this.width);

            seed_cell = this.create_material(
                material_type.SEED,
                material_type.get_default_energy(material_type.SEED)
            );

            cells = [sun_mat; air_mat; earth_mat; immovable_mat];

            cells([this.height / 2, this.width / 2; this.height / 2 + 1, this.width / 2]);
        endfunction

        function colours = get_colours(this)
            colours = cell2mat(arrayfun(@(x) x.type, this.cells, "uniformoutput", false)) + 1;
        endfunction

        function this = next_step(this)
            error("next_step is not implemented.")
        endfunction

        function this = previous_step(this)
            error("previous_step is not implemented.")
        endfunction
    endmethods
endclassdef
