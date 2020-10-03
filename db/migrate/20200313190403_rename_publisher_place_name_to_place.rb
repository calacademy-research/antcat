# frozen_string_literal: true

class RenamePublisherPlaceNameToPlace < ActiveRecord::Migration[6.0]
  def change
    safety_assured do
      rename_column :publishers, :place_name, :place
    end
  end
end
