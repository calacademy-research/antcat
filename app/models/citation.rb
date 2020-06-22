# frozen_string_literal: true

class Citation < ApplicationRecord
  belongs_to :reference

  # TODO: [grep:notes_taxt].
  has_one :protonym, inverse_of: :authorship, foreign_key: :authorship_id, dependent: :destroy

  validates :pages, presence: true

  strip_attributes only: [:pages], replace_newlines: true
  has_paper_trail
end
