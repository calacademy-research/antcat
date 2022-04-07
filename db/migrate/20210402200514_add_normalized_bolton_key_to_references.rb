# frozen_string_literal: true

# TODO: To be used to replace `references.bolton_key`.
class AddNormalizedBoltonKeyToReferences < ActiveRecord::Migration[6.1]
  def change
    add_column :references, :normalized_bolton_key, :string
    add_index :references, :normalized_bolton_key, name: :ix_references__normalized_bolton_key
  end
end
