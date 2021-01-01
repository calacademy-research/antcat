# frozen_string_literal: true

class AddKeyWithSuffixedYearCacheToReferences < ActiveRecord::Migration[6.1]
  def change
    add_column :references, :key_with_suffixed_year_cache, :string
  end
end
