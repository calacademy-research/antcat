class AddReferenceSectionSubtitle < ActiveRecord::Migration
  def change
    add_column :reference_sections, :subtitle, :text
  end
end
