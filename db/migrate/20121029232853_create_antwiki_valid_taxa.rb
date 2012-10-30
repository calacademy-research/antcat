class CreateAntwikiValidTaxa < ActiveRecord::Migration
  def up
    create_table :antwiki_valid_taxa, force: true do |t|
      t.string :name
      t.string :subfamilia
      t.string :tribus
      t.string :genus
      t.string :species
      t.string :binomial
      t.string :binomial_authority
      t.string :subspecies
      t.string :trinomial
      t.string :trinomial_authority
      t.string :author
      t.string :year
      t.string :changed_comb
      t.string :type_locality_country
      t.string :source
      t.string :images
      t.timestamps
    end
  end
end
