class FixDendromyrmex < ActiveRecord::Migration
  def up
    new_name = SubgenusName.create!(
      name:         'Camponotus (Dendromyrmex)',
      name_html:    '<i>Camponotus (Dendromyrmex)</i>',
      epithet:      'Dendromyrmex',
      epithet_html: '<i>Dendromyrmex</i>',
      protonym_html:'<i>Camponotus (Dendromyrmex)</i>',
    )
    spurious_dendromyrmex = Taxon.find 429253
    spurious_dendromyrmex.name = new_name
    spurious_dendromyrmex.save!
  end
end
