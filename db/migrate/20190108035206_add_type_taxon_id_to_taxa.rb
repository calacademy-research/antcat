class AddTypeTaxonIdToTaxa < ActiveRecord::Migration[5.1]
  def change
    add_column :taxa, :type_taxon_id, :integer

    reversible do |dir|
      dir.up do
        execute <<~SQL
          UPDATE taxa AS t_to_migrate
            JOIN names type_names ON t_to_migrate.type_name_id = type_names.id
            JOIN taxa type_taxon ON type_taxon.name_cache = type_names.name
            SET t_to_migrate.type_taxon_id = type_taxon.id;
        SQL

        add_foreign_key :taxa, :taxa, column: :type_taxon_id, name: :fk_taxa__type_taxon_id__taxa__id
      end

      dir.down do
        remove_foreign_key :taxa, name: :fk_taxa__type_taxon_id__taxa__id
      end
    end
  end
end
