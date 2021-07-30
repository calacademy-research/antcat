# frozen_string_literal: true

class RemoveHongFromTaxa < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      remove_column :taxa, :hong, :boolean, default: false, null: false
    end
  end
end
