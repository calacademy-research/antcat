class CreateTaxonomicHistoryItems < ActiveRecord::Migration
  def change
    create_table :taxonomic_history_items, :force => true do |t|
      t.text :text
      t.timestamps
    end
  end
end
