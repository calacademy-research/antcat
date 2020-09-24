# frozen_string_literal: true

class RemoveChangeIdFromVersions < ActiveRecord::Migration[6.0]
  def change
    remove_column :versions, :change_id, :integer
  end
end
