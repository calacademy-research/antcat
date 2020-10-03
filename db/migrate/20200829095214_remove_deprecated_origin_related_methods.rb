# frozen_string_literal: true

# We do not need these any longer since the data has been cleaned up.

class RemoveDeprecatedOriginRelatedMethods < ActiveRecord::Migration[6.0]
  def change
    safety_assured do
      remove_column :taxa, :auto_generated, :boolean, default: false, null: false
      remove_column :taxa, :origin, :string

      remove_column :names, :auto_generated, :boolean, default: false
      remove_column :names, :origin, :string
      remove_column :names, :nonconforming_name, :boolean
    end
  end
end
