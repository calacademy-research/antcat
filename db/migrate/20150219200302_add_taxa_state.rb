class AddTaxaState < ActiveRecord::Migration[4.2]
  def change
    create_table :taxon_states do |t|
      t.integer :taxon_id
      t.string :review_state
      t.boolean :deleted
      t.timestamps
    end
    execute "insert into taxon_states (taxon_id, review_state) select id, review_state from taxa;"

    add_index "taxon_states", ["taxon_id"], name: "taxon_states_taxon_id_idx"

    remove_column :taxa, :review_state

    add_column :versions, :change_id, :integer

        execute "update versions set change_id =
    (SELECT changes.id as change_id
    FROM changes,transactions
    where changes.user_changed_taxon_id = versions.item_id
           and versions.item_type = 'Taxon'
           and transactions.paper_trail_version_id = versions.id
           and transactions.change_id = changes.id order by changes.id desc limit 1);"

    #Create some version history for this object so we can step it back

    drop_table :transactions
  end
end
