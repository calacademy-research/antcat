# frozen_string_literal: true

# TODO: [grep:notes_taxt].
# TODO: rails g migration RemoveFormsAndNotesTaxtFromCitations
# ```
# class RemoveFormsAndNotesTaxtFromCitations < ActiveRecord::Migration[6.0]
#   def up
#     remove_column :citations, :notes_taxt, :text
#     remove_column :citations, :forms, :string
#   end
#
#   def down
#     add_column :citations, :notes_taxt, :text
#     add_column :citations, :forms, :string
#
#     execute <<~SQL
#       UPDATE citations
#         INNER JOIN protonyms ON citations.id = protonyms.authorship_id
#         SET
#           citations.forms = protonyms.forms,
#           citations.notes_taxt = protonyms.notes_taxt;
#     SQL
#   end
# end
# ```
class MoveFormsAndNotesTaxtToProtonyms < ActiveRecord::Migration[6.0]
  def change
    add_column :protonyms, :forms, :string
    add_column :protonyms, :notes_taxt, :text

    reversible do |dir|
      dir.up do
        execute <<~SQL
          UPDATE protonyms
            INNER JOIN citations ON protonyms.authorship_id = citations.id
            SET
              protonyms.forms = citations.forms,
              protonyms.notes_taxt = citations.notes_taxt;
        SQL
      end
    end
  end
end
