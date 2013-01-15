class AddTaxtToReferenceSectionFields < ActiveRecord::Migration
  def change
    rename_column :reference_sections, :title, :title_taxt
    rename_column :reference_sections, :subtitle, :subtitle_taxt
    rename_column :reference_sections, :references, :references_taxt
  end
end
