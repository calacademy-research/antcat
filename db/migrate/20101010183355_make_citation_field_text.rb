class MakeCitationFieldText < ActiveRecord::Migration
  def self.up
    change_column :references, :citation, :text
  end

  def self.down
    change_column :references, :citation, :string
  end
end
