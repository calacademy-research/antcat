class FixNonstandardNotationMigraiton < ActiveRecord::Migration[4.2]
  execute "UPDATE taxa join names
    set taxa.type = substring(names.type, 1, length(names.type) - 4)
    where
    taxa.name_id = names.id and
    taxa.origin = 'migration'  and
    substring(names.type, 1, length(names.type) - 4) != taxa.type"

  execute "UPDATE taxa
    set taxa.display = 0
    where
    taxa.origin = 'migration'      AND
    taxa.status= 'unavailable uncategorized'"
end
