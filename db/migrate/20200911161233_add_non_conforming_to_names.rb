# frozen_string_literal: true

class AddNonConformingToNames < ActiveRecord::Migration[6.0]
  def change
    add_column :names, :non_conforming, :boolean, null: false, default: false
  end
end
