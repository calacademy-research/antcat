class AddPdfLink < ActiveRecord::Migration
  def self.up
    add_column :references, :pdf_link, :string
    add_column :references, :tried_to_get_pdf_link, :boolean
  end

  def self.down
    remove_column :references, :tried_to_get_pdf_link
    remove_column :references, :pdf_link
  end
end
