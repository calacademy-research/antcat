# coding: UTF-8
class AddParseResult < ActiveRecord::Migration
  def self.up
    add_column :deep_species, :parse_result, :string
  end

  def self.down
    remove_column :deep_species, :parse_result
  end
end
