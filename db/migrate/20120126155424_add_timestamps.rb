class AddTimestamps < ActiveRecord::Migration
  def up
    [:author_names, :forward_references, :reference_sections].each do |table|
      change_table table {|t| t.timestamps} rescue nil
    end
  end

  def down
  end
end
