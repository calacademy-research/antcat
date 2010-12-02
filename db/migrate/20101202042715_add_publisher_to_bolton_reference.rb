class AddPublisherToBoltonReference < ActiveRecord::Migration
  def self.up
    add_column :bolton_references, :publisher, :string
  end

  def self.down
    remove_column :bolton_references, :publisher
  end
end
