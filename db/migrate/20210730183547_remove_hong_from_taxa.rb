# frozen_string_literal: true

class RemoveHongFromTaxa < ActiveRecord::Migration[6.1]
  def change
    remove_column :taxa, :hong, :boolean, default: false, null: false
  end
end
