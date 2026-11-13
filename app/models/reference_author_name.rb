# frozen_string_literal: true

# Links a reference to its author names, in order (table `reference_author_names`).
class ReferenceAuthorName < ApplicationRecord
  belongs_to :reference, inverse_of: :reference_author_names
  belongs_to :author_name, inverse_of: :reference_author_names

  acts_as_list scope: :reference
  has_paper_trail
end
