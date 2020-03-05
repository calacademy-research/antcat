class HolData < ActiveRecord::Migration[4.2]
  def change
    create_table :hol_data do |t|
      t.integer :taxon_id
      t.integer :tnuid
      t.integer :tnid
      t.string :name
      t.string :lsid
      t.string :taxon
      t.string :author
      t.string :rank
      t.string :status
      t.string :is_valid
      t.boolean :fossil
      t.integer :num_spms
      t.boolean :many_antcat_references
      t.boolean :many_hol_references
    end

    drop_table :hol_comparisons
  end
end
