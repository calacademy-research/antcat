select names.id, names.name from names left outer join taxa on taxa.name_id = names.id where taxa.id IS NULL;
