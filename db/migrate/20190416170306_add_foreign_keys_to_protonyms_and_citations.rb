class AddForeignKeysToProtonymsAndCitations < ActiveRecord::Migration[5.2]
  def change
    add_foreign_key :protonyms, :citations, column: :authorship_id, name: :fk_protonyms__authorship_id__citations__id
    add_foreign_key :citations, :references, column: :reference_id, name: :fk_citations__reference_id__references__id
  end
end
