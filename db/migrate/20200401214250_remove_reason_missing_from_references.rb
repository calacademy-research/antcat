# frozen_string_literal: true

class RemoveReasonMissingFromReferences < ActiveRecord::Migration[6.0]
  def change
    remove_column :references, :reason_missing, :string
  end
end
