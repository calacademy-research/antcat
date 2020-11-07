# frozen_string_literal: true

class AddEtymologyTaxtToProtonyms < ActiveRecord::Migration[6.0]
  def change
    add_column :protonyms, :etymology_taxt, :text
  end
end
