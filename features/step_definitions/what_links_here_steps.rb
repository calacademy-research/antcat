# frozen_string_literal: true

Given("Eciton has a history item that references Atta and a Batiatus reference") do
  eciton = Protonym.joins(:name).find_by!(names: { name: "Eciton" })
  atta = Taxon.find_by!(name_cache: "Atta")
  reference = create :any_reference, author_string: 'Batiatus'

  create :history_item, :taxt, taxt: "#{Taxt.tax(atta.id)}: #{Taxt.ref(reference.id)}", protonym: eciton
end
