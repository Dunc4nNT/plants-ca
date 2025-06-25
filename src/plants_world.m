classdef plants_world < world
    properties
        % Amount of energy required for a seed to turn into a plant (root/leaf cell).
        seed_to_plant_energy = 25;
        % Amount of energy required for a root to grow.
        grow_root_energy = 25;
        % Amout of earth cells neighbouring a root cell required for the root cell to grow.
        grow_root_earth = 2;
        % Amount of energy required for a leaf to grow.
        grow_leaf_energy = 25;
        % Amout of air cells neighbouring a leaf cell required for the leaf cell to grow.
        grow_leaf_air = 2;
        % Default energy values per material.
        default_immovable_energy = Inf;
        default_sun_energy = Inf;
        default_earth_energy = 1000;
        default_air_energy = 1000;
        default_seed_below_energy = 1000;
        default_seed_above_energy = 1000;
        default_root_energy = 1000;
        default_leaf_energy = 1000;
        default_flower_energy = 1000;
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
                this.default_sun_energy
            );
            sun_mat = repmat(sun_cell, 2, this.width);

            immovable_cell = this.create_material(
                material_type.IMMOVABLE,
                this.default_immovable_energy
            );
            immovable_mat = repmat(immovable_cell, 2, this.width);

            air_cell = this.create_material(
                material_type.AIR,
                this.default_air_energy
            );
            air_mat = repmat(air_cell, this.height / 2 - 2, this.width);

            earth_cell = this.create_material(
                material_type.EARTH,
                this.default_earth_energy
            );
            earth_mat = repmat(earth_cell, this.height / 2 - 2, this.width);

            seed_below_cell = this.create_material(
                material_type.SEED_BELOW,
                this.default_seed_below_energy
            );

            seed_above_cell = this.create_material(
                material_type.SEED_ABOVE,
                this.default_seed_above_energy
            );

            cells = [sun_mat; air_mat; earth_mat; immovable_mat];

            cells(this.height / 2, this.width / 2) = seed_above_cell;
            cells(this.height / 2 + 1, this.width / 2) = seed_below_cell;
        endfunction

        function colours = get_colours(this)
            colours = cell2mat(arrayfun(@(x) x.type, this.cells, "uniformoutput", false)) + 1;
        endfunction

        function this = next_step(this)
            old_cells = this.cells;

            cell_types = cell2mat(arrayfun(@(x) x.type, old_cells, "uniformoutput", false));
            cell_energy = cell2mat(arrayfun(@(x) x.energy, old_cells, "uniformoutput", false));
            air_cells = cell_types == material_type.AIR;
            earth_cells = cell_types == material_type.EARTH;
            seed_above_cells = cell_types == material_type.SEED_ABOVE;
            seed_below_cells = cell_types == material_type.SEED_BELOW;
            leaf_cells = cell_types == material_type.LEAF;
            root_cells = cell_types == material_type.ROOT;
            flower_cells = cell_types == material_type.FLOWER;

            neighbouring_earth_cells = conv2(earth_cells, ones(3), "same");
            neighbouring_air_cells = conv2(air_cells, ones(3), "same");
            inf_inx = cell_energy == Inf;
            cell_energy(inf_inx) = 0;

            % Try turning seeds below the earth into roots.
            seed_below_earth = (neighbouring_earth_cells & seed_below_cells) .* neighbouring_earth_cells;
            seed_below_to_root = logical(logical(seed_below_earth) .* cell_energy >= this.seed_to_plant_energy);

            if sum(sum(seed_below_to_root)) > 0
                this.cells(seed_below_to_root).type = material_type.ROOT;
                this.cells(seed_below_to_root).energy -= this.seed_to_plant_energy;
            endif

            % Try turning seeds above the earth into leafs.
            seed_above_air = (neighbouring_air_cells & seed_above_cells) .* neighbouring_air_cells;
            seed_above_to_leaf = logical(logical(seed_above_air) .* cell_energy >= this.seed_to_plant_energy);

            if sum(sum(seed_above_to_leaf)) > 0
                this.cells(seed_above_to_leaf).type = material_type.LEAF;
                this.cells(seed_above_to_leaf).energy -= this.seed_to_plant_energy;
            endif

            % Try growing roots.
            neighbouring_root_cells = conv2(root_cells, ones(3), "same");
            root_earth = (neighbouring_earth_cells & root_cells) .* neighbouring_earth_cells;
            growable_roots = logical(logical(root_earth) .* cell_energy >= this.grow_root_energy) & root_earth > this.grow_root_earth;
            potential_new_root_cells = earth_cells & conv2(growable_roots, ones(3), "same") & neighbouring_earth_cells > this.grow_root_earth;
            potential_new_root_cells_idx = find(potential_new_root_cells);

            if (size(potential_new_root_cells_idx, 1) > 0)
                earth_to_root = potential_new_root_cells_idx(randi(size(potential_new_root_cells_idx, 1), 1));
                % BUG: fix energy erroring when removing from multiple cells.
                % this.cells(root_cells).energy -= this.grow_root_energy;
                this.cells(earth_to_root).type = material_type.ROOT;
            endif

            % Try growing leafs.
            neighbouring_leaf_cells = conv2(leaf_cells, ones(3), "same");
            leaf_air = (neighbouring_air_cells & leaf_cells) .* neighbouring_air_cells;
            growable_leafs = logical(logical(leaf_air) .* cell_energy >= this.grow_leaf_energy) & leaf_air > this.grow_leaf_air;
            potential_new_leaf_cells = air_cells & conv2(growable_leafs, ones(3), "same") & neighbouring_air_cells > this.grow_leaf_air;
            potential_new_leaf_cells_idx = find(potential_new_leaf_cells);

            if (size(potential_new_leaf_cells_idx, 1) > 0)
                air_to_leaf = potential_new_leaf_cells_idx(randi(size(potential_new_leaf_cells_idx, 1), 1));
                % BUG: fix energy erroring when removing from multiple cells.
                % this.cells(leaf_cells).energy -= this.grow_leaf_energy;
                this.cells(air_to_leaf).type = material_type.LEAF;
            endif

            this.generation++;
        endfunction

        function this = previous_step(this)
            error("previous_step is not implemented.")
        endfunction
    endmethods
endclassdef
