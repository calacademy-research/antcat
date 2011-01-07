class AddGenusColumns < ActiveRecord::Migration
  def self.up
    add_column :genera, :subfamily, :string
    add_column :genera, :tribe, :string
    add_column :genera, :taxonomic_history, :text
    add_column :genera, :current_valid_name, :string
    add_column :genera, :available, :boolean
    add_column :genera, :is_valid, :boolean
  end

  def self.down
    remove_column :genera, :is_valid
    remove_column :genera, :available
    remove_column :genera, :current_valid_name
    remove_column :genera, :taxonomic_history
    remove_column :genera, :tribe
    remove_column :genera, :subfamily
  end
end
