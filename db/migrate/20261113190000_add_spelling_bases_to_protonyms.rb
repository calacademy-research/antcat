# frozen_string_literal: true

# Why AntCat reads a species-group name as it does, and why it accepts the spelling it uses.
# `part_of_speech_basis`: the grammatical basis for `gender_agreement_type` (e.g. decisive usage, Art. 31.2.2).
# `spelling_basis`: the nomenclatural basis for the accepted spelling (e.g. gender agreement, Arts. 31.2, 34.2).
# `interpretation_status`: how firmly AntCat's reading is established (demonstrated, reasonably inferred, disputed,
# unresolved); disputed needs a public note, and disputed or unresolved blocks scripted spelling changes.
class AddSpellingBasesToProtonyms < ActiveRecord::Migration[8.1]
  def change
    change_table :protonyms, bulk: true do |t|
      t.string :part_of_speech_basis
      t.string :spelling_basis
      t.string :interpretation_status
    end
  end
end
