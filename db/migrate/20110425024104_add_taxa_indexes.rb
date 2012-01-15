# coding: UTF-8
class AddTaxaIndexes < ActiveRecord::Migration
  def self.up
    add_index "taxa", ["id", "type"], name: "taxa_id_and_type_idx"
    add_index "taxa", ["name"], name: "taxa_name_idx"
    add_index "taxa", ["type"], name: "taxa_type_idx"
  end

  def self.down
    remove_index "taxa", name: "taxa_type_idx"
    remove_index "taxa", name: "taxa_name_idx"
    remove_index "taxa", name: "taxa_id_and_type_idx"
  end
end
