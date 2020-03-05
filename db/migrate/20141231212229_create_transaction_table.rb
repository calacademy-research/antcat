class CreateTransactionTable < ActiveRecord::Migration[4.2]
  def change
    create_table :transactions do |t|
      t.integer :paper_trail_version_id
      t.integer :change_id
    end

    add_column :changes, :change_type, :string
    add_column :changes, :user_changed_taxon_id, :integer

    execute "insert into transactions (paper_trail_version_id, change_id) select paper_trail_version_id, id from changes;"
    execute "update changes set change_type='create'"
    execute "UPDATE
              changes,versions
             SET
              changes.user_changed_taxon_id = versions.item_id
            WHERE
              changes.paper_trail_version_id = versions.id"

    remove_column :changes, :paper_trail_version_id
  end
end
