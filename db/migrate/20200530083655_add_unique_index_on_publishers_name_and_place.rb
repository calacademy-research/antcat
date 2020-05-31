# frozen_string_literal: true

class AddUniqueIndexOnPublishersNameAndPlace < ActiveRecord::Migration[6.0]
  def change
    add_index :publishers, [:name, :place], unique: true, name: :ux_publishers__name__place
  end
end
