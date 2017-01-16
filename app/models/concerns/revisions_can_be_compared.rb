module RevisionsCanBeCompared
  extend ActiveSupport::Concern

  module ClassMethods
    def revision_comparer_for id, selected_id, diff_with_id
      RevisionComparer.new self, id, selected_id, diff_with_id
    end
  end
end
