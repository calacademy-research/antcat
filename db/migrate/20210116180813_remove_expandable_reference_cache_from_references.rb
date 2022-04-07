# frozen_string_literal: true

class RemoveExpandableReferenceCacheFromReferences < ActiveRecord::Migration[6.1]
  def change
    remove_column :references, :expandable_reference_cache, :text
  end
end
