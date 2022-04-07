# frozen_string_literal: true

class RemoveFossilFromTaxa < ActiveRecord::Migration[6.1]
  def change
    remove_column :taxa, :fossil, :boolean, default: false, null: false
  end
end
