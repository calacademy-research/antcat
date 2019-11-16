class AddReferenceRelatedForeignKeys < ActiveRecord::Migration[5.2]
  def change
    add_foreign_key :author_names, :authors, column: :author_id,
      name: :fk_author_names__author_id__authors__id
    add_foreign_key :references, :journals, column: :journal_id,
      name: :fk_references__journal_id__journals__id
    add_foreign_key :references, :publishers, column: :publisher_id,
      name: :fk_references__publisher_id__publishers__id
    add_foreign_key :reference_author_names, :references, column: :reference_id,
      name: :fk_reference_author_names__reference_id__references__id
    add_foreign_key :reference_author_names, :author_names, column: :author_name_id,
      name: :fk_reference_author_names__author_name_id__author_names__id
  end
end
