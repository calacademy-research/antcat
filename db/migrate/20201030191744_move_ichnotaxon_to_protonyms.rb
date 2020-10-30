# frozen_string_literal: true

# TODO: Remove old column.
#   rails g migration RemoveIchnotaxonFromTaxa
#   remove_column :taxa, :ichnotaxon, :boolean, default: false, null: false
class MoveIchnotaxonToProtonyms < ActiveRecord::Migration[6.0]
  def change
    safety_assured do
      add_column :protonyms, :ichnotaxon, :boolean, default: false, null: false
    end

    reversible do |dir|
      dir.up do
        execute <<~SQL.squish
          UPDATE protonyms
            INNER JOIN taxa ON taxa.protonym_id = protonyms.id
            AND taxa.ichnotaxon = TRUE
            SET protonyms.ichnotaxon = TRUE
        SQL
      end
    end
  end
end
