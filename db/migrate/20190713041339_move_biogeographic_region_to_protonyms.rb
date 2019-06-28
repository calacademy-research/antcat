class MoveBiogeographicRegionToProtonyms < ActiveRecord::Migration[5.2]
  def change
    add_column :protonyms, :biogeographic_region, :string

    reversible do |dir|
      dir.up do
        execute <<~SQL
          UPDATE protonyms
            INNER JOIN taxa ON taxa.protonym_id = protonyms.id
              AND (taxa.biogeographic_region IS NOT NULL)
            SET protonyms.biogeographic_region = taxa.biogeographic_region;
        SQL
      end
    end
  end
end
