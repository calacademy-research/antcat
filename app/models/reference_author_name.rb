# frozen_string_literal: true

class ReferenceAuthorName < ApplicationRecord
  belongs_to :reference, inverse_of: :reference_author_names
  belongs_to :author_name, inverse_of: :reference_author_names

  acts_as_list scope: :reference
  has_paper_trail
end
