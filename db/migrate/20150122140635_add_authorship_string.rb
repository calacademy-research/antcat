class AddAuthorshipString < ActiveRecord::Migration[4.2]
  # These two columns are never actually written to the database. The
  # new rails 4 way says that if you're going to add them as hashes to the
  # activerecord object, they had better correspond to table entries.
  def change
    add_column :taxa, :authorship_string, :string
    add_column :taxa, :duplicate_type, :string
    add_column :taxa, :collision_merge_id, :integer
  end
end
