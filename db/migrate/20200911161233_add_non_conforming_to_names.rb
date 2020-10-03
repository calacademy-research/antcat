# frozen_string_literal: true

class AddNonConformingToNames < ActiveRecord::Migration[6.0]
  def change
    safety_assured do
      add_column :names, :non_conforming, :boolean, null: false, default: false
    end
  end
end
