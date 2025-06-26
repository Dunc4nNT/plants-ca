function next_step()
  # de wereld wordt 1 keer aangemaakt en daarna de hele tijd op verder gegaan
  # (moeten we wss aanpassen als we met knoppen/meer functies enzo werken, maar dit werkt met testen, met globale data werken i.p.v. persistent)
  persistent energy_world cell_types;
  if isempty(energy_world)
    energy_world = zeros(10);

    # Een matrix met de celtypes: zon(1), lucht(2), aarde(3), immovable(4)
    cell_types = zeros(size(energy_world));
    cell_types(1, :) = 1;
    cell_types(2:5, :) = 2;
    cell_types(6:9, :) = 3;
    cell_types(10, :) = 4;

    # Random 5 in de cell_types matrix
    [test1, test2] = deal(randi(size(cell_types, 1)), randi(size(cell_types, 2)));
    cell_types(test1, test2) = 5;
  end

  # het aantal rijen/kolommen van de wereld
  rows = size(energy_world, 1);
  cols = size(energy_world, 2);

  # Cellltypes 1 en 4 hebben altijd 100 (de energiebronnen)
  energy_world(cell_types == 1 | cell_types == 4) = 100;

  # Celltypes 1 en 2 kunnen energie naar beneden doorgeven, 3 en 4 naar boven
  can_give_energy_down = (cell_types == 1) | (cell_types == 2);
  can_give_energy_up = (cell_types == 3) | (cell_types == 4);

  # Celltype 2 kan energie van boven ontvangen, 3 van onder en 5 van beide
  can_recieve_energy_from_above = (cell_types == 2) | (cell_types == 5);
  can_recieve_energy_from_below = (cell_types == 3) | (cell_types == 5);

  # Telt hoe veel cellen links, midden en rechts onder energie kunnen ontvangen van boven
  aantal_buren_onder = zeros(rows, cols);
  if rows > 1
    aantal_buren_onder(1:end-1, 2:end) = aantal_buren_onder(1:end-1, 2:end) + can_recieve_energy_from_above(2:end, 1:end-1);
    aantal_buren_onder(1:end-1, :) = aantal_buren_onder(1:end-1, :) + can_recieve_energy_from_above(2:end, :);
    aantal_buren_onder(1:end-1, 1:end-1) = aantal_buren_onder(1:end-1, 1:end-1) + can_recieve_energy_from_above(2:end, 2:end);
  end

  # Telt hoe veel cellen links, midden en rechts boven energie kunnen ontvangen van onder
  aantal_buren_boven = zeros(rows, cols);
  if rows > 1
    aantal_buren_boven(2:end, 2:end) = aantal_buren_boven(2:end, 2:end) + can_recieve_energy_from_below(1:end-1, 1:end-1);
    aantal_buren_boven(2:end, :) = aantal_buren_boven(2:end, :) + can_recieve_energy_from_below(1:end-1, :);
    aantal_buren_boven(2:end, 1:end-1) = aantal_buren_boven(2:end, 1:end-1) + can_recieve_energy_from_below(1:end-1, 2:end);
  end

  # De hoeveelheid energie die doorgeven wordt naar beneden/boven in matrices
  energy_doorgegeven_beneden = zeros(rows, cols);
  energy_doorgegeven_boven = zeros(rows, cols);

  # Niet / 0, delen door aantal buren die energie kunnen ontvangen.
  deelbaar_beneden = can_give_energy_down & (aantal_buren_onder > 0);
  energy_doorgegeven_beneden(deelbaar_beneden) = energy_world(deelbaar_beneden) ./ aantal_buren_onder(deelbaar_beneden);

  deelbaar_boven = can_give_energy_up & (aantal_buren_boven > 0);
  energy_doorgegeven_boven(deelbaar_boven) = energy_world(deelbaar_boven) ./ aantal_buren_boven(deelbaar_boven);

  next_energy_world = zeros(rows, cols);

  # De energie van celtypes 1 en 2 worden naar links, midden, rechts beneden doorgegeven aan types 2 en 5
  if rows > 1 && cols > 1
    next_energy_world(2:end, 1:end-1) = next_energy_world(2:end, 1:end-1) + energy_doorgegeven_beneden(1:end-1, 2:end) .* can_recieve_energy_from_above(2:end, 1:end-1);
    next_energy_world(2:end, :) = next_energy_world(2:end, :) + energy_doorgegeven_beneden(1:end-1, :) .* can_recieve_energy_from_above(2:end, :);
    next_energy_world(2:end, 2:end) = next_energy_world(2:end, 2:end) + energy_doorgegeven_beneden(1:end-1, 1:end-1) .* can_recieve_energy_from_above(2:end, 2:end);

    # De energie van celtypes 3 en 4 worden naar links, midden, rechts boven doorgegeven aan types 3 en 5
    next_energy_world(1:end-1, 1:end-1) = next_energy_world(1:end-1, 1:end-1) + energy_doorgegeven_boven(2:end, 2:end) .* can_recieve_energy_from_below(1:end-1, 1:end-1);
    next_energy_world(1:end-1, :) = next_energy_world(1:end-1, :) + energy_doorgegeven_boven(2:end, :) .* can_recieve_energy_from_below(1:end-1, :);
    next_energy_world(1:end-1, 2:end) = next_energy_world(1:end-1, 2:end) + energy_doorgegeven_boven(2:end, 1:end-1) .* can_recieve_energy_from_below(1:end-1, 2:end);
  end

  # De energie van celtypes 1 en 4 wordt weer op 100 gezet, omdat dit de energie bronnen zijn
  next_energy_world(cell_types == 1 | cell_types == 4) = 100;

  energy_world = next_energy_world;

  disp(energy_world);
  disp(cell_types);
endfunction
