# frozen_string_literal: true

class RemoveUncertainLocalityFromProtonyms < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      remove_column :protonyms, :uncertain_locality, :boolean, default: false, null: false
    end
  end
end
