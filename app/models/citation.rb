# frozen_string_literal: true

# TODO: [grep:notes_taxt].
# This class is currently only used in `Protonym`, where the association
# is called `authorship`. I believe the plan was to use this in more places,
# say in taxt items, but that never happened. We may want to rename
# `protonyms.authorship_id` in any case.

class Citation < ApplicationRecord
  belongs_to :reference

  has_one :protonym, inverse_of: :authorship, foreign_key: :authorship_id, dependent: :destroy

  validates :pages, presence: true

  strip_attributes only: [:pages], replace_newlines: true
  has_paper_trail
end
