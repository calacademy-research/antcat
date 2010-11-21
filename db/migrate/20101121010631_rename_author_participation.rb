class RenameAuthorParticipation < ActiveRecord::Migration
  def self.up
    rename_table :author_participations, :reference_author_names
  end

  def self.down
    rename_table :reference_author_names, :author_participations
  end
end
