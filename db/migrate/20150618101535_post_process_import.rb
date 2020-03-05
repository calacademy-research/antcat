class PostProcessImport < ActiveRecord::Migration[4.2]
  def change
    # This makes the type
    execute 'update taxa
  join (
    select   antcat_taxon_id,  substring(names.type,1,length(names.type)-4)  as magic_type
    from hol_taxon_data
      join taxa on antcat_taxon_id = taxa.id
      join names on taxa.name_id = names.id
    group by antcat_taxon_id
       ) as sq on sq.antcat_taxon_id = taxa.id
set taxa.type = sq.magic_type
WHERE
  taxa.type != sq.magic_type AND
  (sq.magic_type = "Species" or sq.magic_type = "Subspecies") and
  taxa.type != "Genus" AND  instr(name_cache,".") =0 and
  taxa.auto_generated=true'

    execute "ALTER TABLE hol_taxon_data CONVERT TO CHARACTER SET utf8 COLLATE utf8_unicode_ci"
  end
end
