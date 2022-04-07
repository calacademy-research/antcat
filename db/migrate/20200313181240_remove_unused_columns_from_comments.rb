# frozen_string_literal: true

class RemoveUnusedColumnsFromComments < ActiveRecord::Migration[6.0]
  def change
    remove_column :comments, :title, :text
    remove_column :comments, :subject, :string
    remove_column :comments, :parent_id, :integer
    remove_column :comments, :lft, :integer
    remove_column :comments, :rgt, :integer
  end
end
