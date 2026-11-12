# frozen_string_literal: true

# The masculine, feminine and neuter spellings of an adjectival or participial species-group name,
# as TaxonWorks stores them (there: `masculine_name`, `feminine_name`, `neuter_name`).
class AddGenderEpithetsToProtonyms < ActiveRecord::Migration[8.1]
  def change
    change_table :protonyms, bulk: true do |t|
      t.string :masculine_epithet
      t.string :feminine_epithet
      t.string :neuter_epithet
    end
  end
end
