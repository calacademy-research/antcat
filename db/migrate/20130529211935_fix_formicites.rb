class FixFormicites < ActiveRecord::Migration
  def up
    CollectiveGroupName.first.update_attributes!(
      name_html:    '<i>Formicites</i>',
      epithet_html: '<i>Formicites</i>',
      protonym_html:'<i>Formicites</i>',
    )
  end

  def down
  end
end
