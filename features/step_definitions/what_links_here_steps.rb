# frozen_string_literal: true

Given("Eciton has a taxonomic history item that references Atta and a Batiatus reference") do
  eciton = Taxon.find_by(name_cache: "Eciton")
  atta = Taxon.find_by(name_cache: "Atta")
  reference = create :any_reference, author_name: 'Batiatus'

  create :taxon_history_item, taxt: "{tax #{atta.id}}: {ref #{reference.id}}", taxon: eciton
end
