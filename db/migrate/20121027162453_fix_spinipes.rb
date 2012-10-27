class FixSpinipes < ActiveRecord::Migration
  def up
    spinipes = Taxon.find_by_name 'Aphaenogaster spinipes'
    return unless spinipes

    # set name
    correct_name = Name.find_by_name 'Aphaenogaster swammerdami spinipes'
    spinipes.update_attribute :name_id, correct_name.id

    # delete first 3 history items
    3.times {|i| spinipes.history_items.first.destroy}

    # set type
    Taxon.connection.execute %{UPDATE taxa SET type = 'Subspecies' WHERE id = '#{spinipes.id}'}
    spinipes = Taxon.find spinipes.id

    # set species
    species = Taxon.find_by_name 'Aphaenogaster swammerdami'
    spinipes.update_attribute :species_id, species.id

    # change protonym name
    protonym_name = spinipes.protonym.name
    new_protonym_html = protonym_name.protonym_html + '[sic] var. <i>spinipes</i>'
    protonym_name.update_attribute :protonym_html, new_protonym_html

    # fix locality
    protonym = spinipes.protonym
    protonym.locality = 'Madagascar'
    protonym.save!

    # fix authorship
    reference = Reference.find_by_bolton_key_cache 'Santschi 1911e'
    protonym.authorship = Citation.create! reference: reference, pages: '123', forms: 'w.'
    protonym.save!
  end

end
