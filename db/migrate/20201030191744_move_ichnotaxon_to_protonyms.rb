# frozen_string_literal: true

class MoveIchnotaxonToProtonyms < ActiveRecord::Migration[6.0]
  def change
    add_column :protonyms, :ichnotaxon, :boolean, default: false, null: false

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
