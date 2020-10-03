# frozen_string_literal: true

class AddUncertainLocalityToProtonyms < ActiveRecord::Migration[6.0]
  def change
    safety_assured do
      add_column :protonyms, :uncertain_locality, :boolean, null: false, default: false
    end
  end
end
