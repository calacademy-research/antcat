class RenameToSourceUrl < ActiveRecord::Migration
  def self.up
    change_table  :references do |t|
      t.rename :pdf_link, :source_url
      t.remove :tried_to_get_pdf_link
    end
  end

  def self.down
    change_table  :references do |t|
      t.string :tried_to_get_pdf_link
      t.rename :source_url, :pdf_link
    end
  end
end
