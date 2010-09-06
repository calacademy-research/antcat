class AddIssueToArticle < ActiveRecord::Migration
  def self.up
    change_table(:sources) {|t| t.integer :issue_id}
  end

  def self.down
    change_table(:sources) {|t| t.remove :issue_id}
  end
end
