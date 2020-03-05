class FixCurrentValid < ActiveRecord::Migration[4.2]
  def change
    execute "update taxa
    set taxa.current_valid_taxon_id = null where current_valid_taxon_id = id"

    execute "UPDATE
    taxa
    INNER JOIN
    taxa as b
    SET
    taxa.current_valid_taxon_id = b.current_valid_taxon_id
    where
    taxa.current_valid_taxon_id = b.id and b.current_valid_taxon_id is not null AND
    taxa.status != 'valid'"

    execute "update taxa
    set taxa.current_valid_taxon_id = null where current_valid_taxon_id = id"

    execute "UPDATE
    taxa
    INNER JOIN
    taxa as b
    SET
    taxa.current_valid_taxon_id = b.current_valid_taxon_id
    where
    taxa.current_valid_taxon_id = b.id and b.current_valid_taxon_id is not null AND
    taxa.status != 'valid'"
    execute "update taxa
    set taxa.current_valid_taxon_id = null where current_valid_taxon_id = id"
  end
end
