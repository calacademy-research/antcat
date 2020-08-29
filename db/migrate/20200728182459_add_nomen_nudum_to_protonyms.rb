# frozen_string_literal: true

class AddNomenNudumToProtonyms < ActiveRecord::Migration[6.0]
  def change
    add_column :protonyms, :nomen_nudum, :boolean, default: false, null: false

    reversible do |dir|
      dir.up do
        execute <<~SQL
          UPDATE protonyms
            INNER JOIN taxa ON taxa.protonym_id = protonyms.id
            AND taxa.nomen_nudum = TRUE
            SET protonyms.nomen_nudum = TRUE;
        SQL
      end
    end
  end
end
