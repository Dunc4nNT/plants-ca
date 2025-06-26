classdef plants_world
    properties
        width;
        height;
        generation;
        type_cells;
        energy_cells;
        start_generation_at;
        colourmap;

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
        % Amount of energy a new root cell starts with.
        root_start_energy = 5;
        % Amount of energy a new leaf cell starts with.
        leaf_start_energy = 5;
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
        function this = plants_world(width, height, start_generation_at = uint32(0))
            if (this._is_valid_size(width, "Width"))
                this.width = width;
            endif

            if (this._is_valid_size(height, "Height"))
                this.height = height;
            endif

            this.start_generation_at = start_generation_at;
            [this.type_cells, this.energy_cells] = this.get_preset_cells();
            this.generation = this.start_generation_at;
            this.colourmap = material_type.get_colourmap();
        endfunction

        function this = reset_world(this)
            [this.type_cells, this.energy_cells] = this.get_preset_cells();
            this = this.reset_generation();
        endfunction

        function this = set_cells(this, type_cells, energy_cells)
            if (!isequal(size(type_cells), size(energy_cells)))
                error("type_cells and energy_cells must be of equal size.")
            endif

            if (ndims(type_cells) != 2 | ndims(energy_cells) != 2)
                error("New world cells must have exactly two dimensions.");
                return;
            endif

            this.width = rows(type_cells);
            this.height = columns(type_cells);
            this.type_cells = type_cells;
            this.energy_cells = energy_cells;
            this = this.reset_generation();
        endfunction

        function this = set_cell(this, x, y, type, energy)
            if (x < 1 | x > columns(this.type_cells) | y < 1 | y > rows(this.type_cells))
                error("Cell index is out of range.");
            endif

            this.type_cells(y, x) = type;
            this.energy_cells(y, x) = energy;
        endfunction

        function [type_cells, energy_cells] = get_cells(this)
            type_cells = this.type_cells;
            energy_cells = this.energy_cells;
        endfunction

        function [type_cell, energy_cell] = get_cell(this, x, y)
            type_cell = this.type_cells(y, x);
            energy_cell = this.energy_cells(y, x);
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

        function [type_cells, energy_cells] = get_preset_cells(this)
            sun_type_cells = repmat(material_type.SUN, 2, this.width);
            sun_energy_cells = repmat(this.default_sun_energy, 2, this.width);
            immovable_type_cells = repmat(material_type.IMMOVABLE, 2, this.width);
            immovable_energy_cells = repmat(this.default_immovable_energy, 2, this.width);
            air_type_cells = repmat(material_type.AIR, this.height / 2 - 2, this.width);
            air_energy_cells = repmat(this.default_air_energy, this.height / 2 - 2, this.width);
            earth_type_cells = repmat(material_type.EARTH, this.height / 2 - 2, this.width);
            earth_energy_cells = repmat(this.default_earth_energy, this.height / 2 - 2, this.width);

            type_cells = [sun_type_cells; air_type_cells; earth_type_cells; immovable_type_cells];
            energy_cells = [sun_energy_cells; air_energy_cells; earth_energy_cells; immovable_energy_cells];

            type_cells(this.height / 2 + 1, this.width / 2) = material_type.SEED_BELOW;
            energy_cells(this.height / 2 + 1, this.width / 2) = this.default_seed_below_energy;
            type_cells(this.height / 2, this.width / 2) = material_type.SEED_ABOVE;
            energy_cells(this.height / 2, this.width / 2) = this.default_seed_above_energy;
        endfunction

        function colours = get_colours(this)
            colours = this.type_cells + 1;
        endfunction

        function this = next_step(this)
            cell_types = this.type_cells;
            cell_energy = this.energy_cells;
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
                this.type_cells(seed_below_to_root) = material_type.ROOT;
                this.energy_cells(seed_below_to_root) -= this.seed_to_plant_energy;
            endif

            % Try turning seeds above the earth into leafs.
            seed_above_air = (neighbouring_air_cells & seed_above_cells) .* neighbouring_air_cells;
            seed_above_to_leaf = logical(logical(seed_above_air) .* cell_energy >= this.seed_to_plant_energy);

            if sum(sum(seed_above_to_leaf)) > 0
                this.type_cells(seed_above_to_leaf) = material_type.LEAF;
                this.energy_cells(seed_above_to_leaf) -= this.seed_to_plant_energy;
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
                this.energy_cells(root_cells) -= this.grow_root_energy;
                this.type_cells(earth_to_root) = material_type.ROOT;
                this.energy_cells(earth_to_root) = this.root_start_energy;
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
                this.energy_cells(leaf_cells) -= this.grow_leaf_energy;
                this.type_cells(air_to_leaf) = material_type.LEAF;
                this.energy_cells(air_to_leaf) = this.leaf_start_energy;
            endif

            this.generation++;
        endfunction

        function this = previous_step(this)
            error("previous_step is not implemented.")
        endfunction
    endmethods
endclassdef
