class AddTimestampsBackToReferenceSections < ActiveRecord::Migration
  def change
    change_table :reference_sections do |t|
      t.timestamps
    end
  end
end
