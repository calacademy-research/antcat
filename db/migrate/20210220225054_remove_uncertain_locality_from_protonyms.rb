# frozen_string_literal: true

class RemoveUncertainLocalityFromProtonyms < ActiveRecord::Migration[6.1]
  def change
    remove_column :protonyms, :uncertain_locality, :boolean, default: false, null: false
  end
end
