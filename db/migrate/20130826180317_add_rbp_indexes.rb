class AddRbpIndexes < ActiveRecord::Migration
  def up
    add_index :bolton_references, :match_id 
    add_index :changes, :paper_trail_version_id
    add_index :changes, :approver_id
    add_index :forward_refs, [:fixee_id, :fixee_type]
    add_index :forward_refs, :name_id
    add_index :users, [:invited_by_id, :invited_by_type]
  end

  def down
    remove_index :users, column: [:invited_by_id, :invited_by_type]
    remove_index :forward_refs, column: :name_id
    remove_index :forward_refs, column: [:fixee_id, :fixee_type]
    remove_index :changes, column: :approver_id
    remove_index :changes, column: :paper_trail_version_id
    remove_index :bolton_references, column: :match_id
  end
end
