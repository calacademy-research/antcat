class AuthorshipToReferenceLocation < ActiveRecord::Migration
  def self.up
    rename_table :authorships, :reference_locations rescue nil
  end

  def self.down
  end
end
