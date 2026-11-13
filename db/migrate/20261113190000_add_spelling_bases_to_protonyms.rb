# frozen_string_literal: true

# Why AntCat reads a species-group name as it does, and why it accepts the spelling it uses.
# `part_of_speech_basis`: the grammatical basis for `gender_agreement_type` (e.g. decisive usage, Art. 31.2.2).
# `spelling_basis`: the nomenclatural basis for the accepted spelling (e.g. gender agreement, Arts. 31.2, 34.2).
# `interpretation_contested`: AntCat adopts one defensible reading over another; a public note gives the alternative.
class AddSpellingBasesToProtonyms < ActiveRecord::Migration[8.1]
  def change
    change_table :protonyms, bulk: true do |t|
      t.string :part_of_speech_basis
      t.string :spelling_basis
      t.boolean :interpretation_contested, null: false, default: false
    end
  end
end
