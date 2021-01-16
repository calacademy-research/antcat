# frozen_string_literal: true

class RemoveExpandableReferenceCacheFromReferences < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      remove_column :references, :expandable_reference_cache, :text
    end
  end
end
