classdef plants_world < world
    properties
        seed_to_plant_energy = 25;
    endproperties

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

            seed_below_cell = this.create_material(
                material_type.SEED_BELOW,
                50
            );

            seed_above_cell = this.create_material(
                material_type.SEED_ABOVE,
                50
            );

            cells = [sun_mat; air_mat; earth_mat; immovable_mat];

            cells(this.height / 2, this.width / 2) = seed_above_cell;
            cells(this.height / 2 + 1, this.width / 2) = seed_below_cell;
        endfunction

        function colours = get_colours(this)
            colours = cell2mat(arrayfun(@(x) x.type, this.cells, "uniformoutput", false)) + 1;
        endfunction

        function this = next_step(this)
            new_cells = this.cells;

            cell_types = cell2mat(arrayfun(@(x) x.type, this.cells, "uniformoutput", false));
            cell_energy = cell2mat(arrayfun(@(x) x.energy, this.cells, "uniformoutput", false));
            air_cells = cell_types == material_type.AIR;
            earth_cells = cell_types == material_type.EARTH;
            seed_above_cells = cell_types == material_type.SEED_ABOVE;
            seed_below_cells = cell_types == material_type.SEED_BELOW;

            neighbouring_air_cells = conv2(air_cells, ones(3), "same");
            seed_above_air = (neighbouring_air_cells & seed_above_cells) .* neighbouring_air_cells;
            neighbouring_earth_cells = conv2(earth_cells, ones(3), "same");
            seed_below_earth = (neighbouring_earth_cells & seed_below_cells) .* neighbouring_earth_cells;
            inf_inx = cell_energy == Inf;
            cell_energy(inf_inx) = 0;
            seed_above_to_leaf = logical(logical(seed_above_air) .* cell_energy >= this.seed_to_plant_energy);
            seed_below_to_root = logical(logical(seed_below_earth) .* cell_energy >= this.seed_to_plant_energy);

            % seed_above_neighbours = conv2(seed_above_cell, ones(3), "valid");
            % seed_above_neighbours = [zeros(1, columns(seed_above_neighbours)); seed_above_neighbours; zeros(1, columns(seed_above_neighbours))];
            % seed_above_neighbours = [zeros(rows(seed_above_neighbours), 1), seed_above_neighbours, zeros(rows(seed_above_neighbours), 1)];
            % seed_above_neighbours = (air_cells + seed_above_neighbours)

            if sum(sum(seed_above_to_leaf)) > 0
                new_cells(seed_above_to_leaf).type = material_type.LEAF;
                new_cells(seed_above_to_leaf).energy -= this.seed_to_plant_energy;
            endif

            if sum(sum(seed_below_to_root)) > 0
                new_cells(seed_below_to_root).type = material_type.ROOT;
                new_cells(seed_below_to_root).energy -= this.seed_to_plant_energy;
            endif

            this.cells = new_cells;
        endfunction

        function this = previous_step(this)
            error("previous_step is not implemented.")
        endfunction
    endmethods
endclassdef
