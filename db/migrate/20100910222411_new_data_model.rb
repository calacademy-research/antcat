class NewDataModel < ActiveRecord::Migration
  def self.up
    drop_table :references
    rename_table :ward_references, :references
    change_table :references do |t|
      t.remove :authors
      t.string :citation_year
      t.remove :reference_id
      t.string :type
      t.integer :publisher_id
      t.integer :journal_id
      t.string :issue
      t.string :pagination
    end rescue nil
    rename_column :author_participations, :source_id, :reference_id
    drop_table :sources

    create_table :publishers do |t|
      t.string :name
      t.string :place
      t.timestamps
    end
  end

  def self.down
    drop_table :publishers
    rename_column :author_participations, :reference_id, :source_id
    change_table :references do |t|
      t.string :authors
      t.remove :citation_year
      t.integer :reference_id
      t.remove :type
      t.remove :publisher_id
      t.remove :journal_id
      t.remove :issue
      t.remove :pagination
    end
    rename_table :references, :ward_references
    create_table :references
    create_table :sources
  end
end
