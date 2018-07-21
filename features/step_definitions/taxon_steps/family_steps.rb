Given("the Formicidae family exists") do
  reference = create :article_reference,
    author_names: [create(:author_name, name: 'Latreille, I.')],
    citation_year: '1809',
    title: 'Ants'

  protonym = create :protonym,
    name: create(:subfamily_name, name: "Formicariae"),
    authorship: create(:citation, reference: reference, pages: "124")

  create :family,
    name: create(:family_name, name: "Formicidae"),
    protonym: protonym,
    type_name: create(:genus_name, name: "Formica"),
    history_items: [create(:taxon_history_item)]
end
