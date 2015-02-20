class AddTaxaState < ActiveRecord::Migration
  def change
    create_table :taxon_states do |t|
      t.integer :taxon_id
      t.string :review_state
      t.boolean :deleted
      t.string :deleted_name
    end
    execute "insert into taxon_states (taxon_id, review_state) select id, review_state from taxa;"
    add_index "taxon_states", ["taxon_id"], :name => "taxon_states_taxon_id_idx"

   # remove_column :taxa, :review_state
  end
end
