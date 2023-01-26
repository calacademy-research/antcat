# frozen_string_literal: true

def eciton_has_a_history_item_that_references_atta_and_a_batiatus_reference
  eciton = Protonym.joins(:name).find_by!(names: { name: "Eciton" })
  atta = Taxon.find_by!(name_cache: "Atta")
  reference = create :any_reference, author_string: 'Batiatus'

  create :history_item, :taxt, taxt: "#{Taxt.tax(atta.id)}: #{Taxt.ref(reference.id)}", protonym: eciton
end
