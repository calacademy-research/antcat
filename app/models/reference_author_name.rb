class ReferenceAuthorName < ApplicationRecord
  belongs_to :reference
  belongs_to :author_name

  acts_as_list scope: :reference
  has_paper_trail meta: { change_id: proc { UndoTracker.current_change_id } }

  before_save :invalidate_reference_caches!
  before_destroy :invalidate_reference_caches!

  private

    def invalidate_reference_caches!
      reference.reload
      reference.invalidate_caches
    end
end
