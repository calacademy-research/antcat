# frozen_string_literal: true

class Citation < ApplicationRecord
  belongs_to :reference

  # TODO: [grep:notes_taxt].
  has_one :protonym, inverse_of: :authorship, foreign_key: :authorship_id, dependent: :destroy

  validates :pages, presence: true

  # NOTE: Good enough for now (MySQL 5). It does not handle Roman numerals or other complicated formats.
  scope :order_by_pages, -> { order(Arel.sql("CAST(pages AS UNSIGNED), pages")) }

  strip_attributes only: [:pages], replace_newlines: true
  has_paper_trail
end
