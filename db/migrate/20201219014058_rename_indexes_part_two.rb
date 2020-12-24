# frozen_string_literal: true

class RenameIndexesPartTwo < ActiveRecord::Migration[6.1]
  def up
    remove_index :reference_documents, name: :documents_reference_id_idx
    # Looked like this: `t.index ["object_protonym_id"], name: "ix_history_items__object_taxon_id"`
    # Commented out index that was ninja changed on production:
    # remove_index :history_items, name: :ix_history_items__object_taxon_id

    remove_index :references, name: :references_author_names_string_citation_year_idx
    add_index :references, :author_names_string_cache, name: :ix_x_references__author_names_string_cache,
      length: { author_names_string_cache: 255 }
  end

  def down
    add_index :reference_documents, :reference_id, name: :documents_reference_id_idx
    # Commented out index that was ninja changed on production:
    # add_index :history_items, :object_protonym_id, name: :ix_history_items__object_taxon_id

    add_index :references, :author_names_string_cache, name: :references_author_names_string_citation_year_idx,
      length: { author_names_string_cache: 255 }
    remove_index :references, name: :ix_x_references__author_names_string_cache
  end
end
