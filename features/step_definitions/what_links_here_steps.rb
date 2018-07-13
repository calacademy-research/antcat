Given("Eciton has a taxonomic history item that mentions Atta and a Batiatus reference") do
  atta = Taxon.find_by name_cache: "Atta"
  eciton = Taxon.find_by name_cache: "Eciton"
  reference = create :article_reference, citation_year: 2000,
    author_names: [create(:author_name, name: "Batiatus, Q.")]

  taxt = "As a synonym of {tax #{atta.id}}: {ref #{reference.id}}"
  eciton.history_items.create! taxt: taxt
end
